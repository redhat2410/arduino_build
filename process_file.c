#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char* Read(char* filename);
void Write(char* filename, char* data);
char* rmchar(char* input, char chr);
int isFileExist(char* filename);

char* str_cmp = "#include";
char* str_cmp_1 = "Arduino.h";
char* str_cmp_2 = "SoftwareSerial.h";
char* str_cmp_3 = "Wire.h";
char* str_cmp_4 = "SPI.h";
char* str_cmp_5 = "EEPROM.h";
char* str_cmp_6 = "HID.h";

int main(int argc, char** argv){
    char* str = Read(argv[1]);
    char* token;
    int index = 0;
    char* result = (char*)malloc( 30 * sizeof(char) );
    token = strtok(str, "\n");
    while(token != NULL){
        if(strstr(token, str_cmp_1) == NULL && strstr(token, str_cmp_2) == NULL &&
                strstr(token, str_cmp_3) == NULL && strstr(token, str_cmp_4) == NULL &&
                strstr(token, str_cmp_5) == NULL && strstr(token, str_cmp_6) == NULL)
        {
            if(strstr(token, str_cmp) != NULL) {
                sscanf(token, "#include < %s >", result);
                if(strchr(result, '>') != NULL)
                    result = rmchar(result, '>');
                Write("header.conf", result);
            }
        }
        index++;
        token = strtok(NULL, "\n");
    }
    printf("done...");
    return 0;
}
//Hàm Read thực hiện đọc dữ liệu ra từ file
char* Read(char* filename){
    FILE* f;
    char ch;
    int size = 0, index = 0;
    char* result;
    f = fopen(filename, "r");
    fseek(f, 0, SEEK_END);
    size = ftell(f);
    result = (char*)malloc( size * sizeof(char) );
    fseek(f, 0, SEEK_SET);

    if(f == NULL || result == NULL){
        printf("Error.");
        return NULL;
    }

    while( (ch = fgetc(f)) != EOF ){
        result[index++] = ch;
    }
    fclose(f);
    return result;
} 
//Hàm Write thực hiện ghi dự liệu vào file 
void Write(char* filename, char* data){
    FILE* f;
    if(!isFileExist(filename)){
        f = fopen(filename, "w");
        fprintf(f, "%s\n", data);
    }
    else{
        f = fopen(filename, "a");
        fprintf(f, "%s\n", data);
    }
    fclose(f);
}

void Process(char* data){

}
//Ham thực hiện xóa ký tự > trong chuỗi
char* rmchar(char* input, char chr){
    char *result = (char*)malloc( strlen(input) * sizeof(char));
    int size=0;
    for(int i = 0; i < strlen(input); i++){
        if(input[i] == chr){
            size = i;
            result[i] = 0;
            break;
        }
        result[i] = input[i];
    }
    return result;
}

int isFileExist(char *filename){
    FILE* f = fopen(filename, "r");
    if(f == NULL) return 0;
    fclose(f);
    return 1;
}