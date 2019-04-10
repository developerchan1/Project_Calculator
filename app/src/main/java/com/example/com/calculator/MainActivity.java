package com.example.com.calculator;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    Button calculate;
    EditText number1, number2;
    Spinner spinner_operator;
    TextView hasil;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        calculate = findViewById(R.id.btn_Calculate);
        number1 = findViewById(R.id.et_Value1);
        number2 = findViewById(R.id.et_Value2);
        spinner_operator = findViewById(R.id.operator);
        hasil = findViewById(R.id.tv_result);

        String [] operator = {"Add","Subtract","Multiple","Divide"};
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,android.R.layout.simple_dropdown_item_1line,operator);
        spinner_operator.setAdapter(adapter);

        calculate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                double number1S = 0;
                double number2S = 0;
                boolean valid = true;

                try{
                    number1S = Double.parseDouble(number1.getText().toString());
                    number2S = Double.parseDouble(number2.getText().toString());
                }catch(Exception e){
                    valid = false;
                }

                if(valid){
                    String choice = spinner_operator.getSelectedItem().toString();

                    if(choice.equals("Add")){
                        hasil.setText(String.valueOf(number1S+number2S));
                    }
                    else
                    if(choice.equals("Subtract")){
                        hasil.setText(String.valueOf(number1S-number2S));
                    }
                    else
                    if(choice.equals("Multiple")){
                        hasil.setText(String.valueOf(number1S*number2S));
                    }
                    else
                    if(choice.equals("Divide")){
                        if(number2S == 0){
                            hasil.setText("Can't divided by zero!!");
                        }
                        else{
                            if(number1S % number2S == 0){
                                hasil.setText(String.valueOf(number1S/number2S));
                            }
                            else
                            hasil.setText(String.valueOf((double)number1S/number2S));
                        }

                    }
                }
                else
                {
                    Toast.makeText(MainActivity.this, "Inputs doesn't valid", Toast.LENGTH_SHORT).show();
                }
            }
        });

    }
}
