// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'message_codec.dart';
import 'message_codecs.dart';
import 'platform_messages.dart';

/// A named channel for communicating with platform plugins using asynchronous
/// message passing.
///
/// Messages are encoded into binary before being sent, and binary messages
/// received are decoded into Dart values. The [MessageCodec] used must be
/// compatible with the one used by the platform plugin. This can be achieved
/// by creating a basic message channel counterpart of this channel on the
/// platform side. The Dart type of messages sent and received is [T],
/// but only the values supported by the specified [MessageCodec] can be used.
/// The use of unsupported values should be considered programming errors, and
/// will result in exceptions being thrown. The null message is supported
/// for all codecs.
///
/// The logical identity of the channel is given by its name. Identically named
/// channels will interfere with each other's communication.
///
/// See: <https://flutter.io/platform-channels/>
class BasicMessageChannel<T> {
  /// Creates a [BasicMessageChannel] with the specified [name] and [codec].
  ///
  /// Neither [name] nor [codec] may be null.
  const BasicMessageChannel(this.name, this.codec);

  /// The logical channel on which communication happens, not null.
  final String name;

  /// The message codec used by this channel, not null.
  final MessageCodec<T> codec;

  /// Sends the specified [message] to the platform plugins on this channel.
  ///
  /// Returns a [Future] which completes to the received response, which may
  /// be null.
  Future<T> send(T message) async {
    return codec.decodeMessage(await BinaryMessages.send(name, codec.encodeMessage(message)));
  }

  /// Sets a callback for receiving messages from the platform plugins on this
  /// channel. Messages may be null.
  ///
  /// The given callback will replace the currently registered callback for this
  /// channel, if any. To remove the handler, pass null as the `handler`
  /// argument.
  ///
  /// The handler's return value is sent back to the platform plugins as a
  /// message reply. It may be null.
  void setMessageHandler(Future<T> handler(T message)) {
    if (handler == null) {
      BinaryMessages.setMessageHandler(name, null);
    } else {
      BinaryMessages.setMessageHandler(name, (ByteData message) async {
        return codec.encodeMessage(await handler(codec.decodeMessage(message)));
      });
    }
  }

  /// Sets a mock callback for intercepting messages sent on this channel.
  /// Messages may be null.
  ///
  /// The given callback will replace the currently registered mock callback for
  /// this channel, if any. To remove the mock handler, pass null as the
  /// `handler` argument.
  ///
  /// The handler's return value is used as a message reply. It may be null.
  ///
  /// This is intended for testing. Messages intercepted in this manner are not
  /// sent to platform plugins.
  void setMockMessageHandler(Future<T> handler(T message)) {
    if (handler == null) {
      BinaryMessages.setMockMessageHandler(name, null);
    } else {
      BinaryMessages.setMockMessageHandler(name, (ByteData message) async {
        return codec.encodeMessage(await handler(codec.decodeMessage(message)));
      });
    }
  }
}

/// A named channel for communicating with platform plugins using asynchronous
/// method calls.
///
/// Method calls are encoded into binary before being sent, and binary results
/// received are decoded into Dart values. The [MethodCodec] used must be
/// compatible with the one used by the platform plugin. This can be achieved
/// by creating a method channel counterpart of this channel on the
/// platform side. The Dart type of arguments and results is `dynamic`,
/// but only values supported by the specified [MethodCodec] can be used.
/// The use of unsupported values should be considered programming errors, and
/// will result in exceptions being thrown. The null value is supported
/// for all codecs.
///
/// The logical identity of the channel is given by its name. Identically named
/// channels will interfere with each other's communication.
///
/// See: <https://flutter.io/platform-channels/>
class MethodChannel {
  /// Creates a [MethodChannel] with the specified [name].
  ///
  /// The [codec] used will be [StandardMethodCodec], unless otherwise
  /// specified.
  ///
  /// Neither [name] nor [codec] may be null.
  const MethodChannel(this.name, [this.codec = const StandardMethodCodec()]);

  /// The logical channel on which communication happens, not null.
  final String name;

  /// The message codec used by this channel, not null.
  final MethodCodec codec;

  /// Invokes a [method] on this channel with the specified [arguments].
  ///
  /// The static type of [arguments] is `dynamic`, but only values supported by
  /// the [codec] of this channel can be used. The same applies to the retu