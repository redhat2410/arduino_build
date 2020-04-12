#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>

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

//define path path.conf
char* _pathPathFileConf = "etc\\path.conf";

int main(int argc, char** argv){
    DIR* dir;
    char* str = Read(_pathPathFileConf);
    printf("%s\n", str);
    str = rmchar(str, '\n');
    printf("%s\n", str);
    str = rmchar(str, '"');
    printf("%s\n", str);

    strcat(str, "\\hardware\\arduino\\avr\\cores\\arduino");
    printf("%s\n", str);
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
/*
    Hàm writeFileConf thực hiện xử lý file source code được truyền vào
    Lấy các header được include trong file và ghi vào file header.conf
    @param filename: đường dẫn tới file source code
    @return : none
*/
void writeFileConf(char* filename){
    char* token;
    char* result = (char*)malloc( 30 * sizeof(char));
    char* str = Read(filename);
    int index = 0;
    token = strtok(str, "\n");
    while(token != NULL){
        //kiểm tra vào loại bỏ các header được define
        if(strstr(token, str_cmp_1) == NULL && strstr(token, str_cmp_2) == NULL &&
                strstr(token, str_cmp_3) == NULL && strstr(token, str_cmp_4) == NULL &&
                strstr(token, str_cmp_5) == NULL && strstr(token, str_cmp_6) == NULL)
        {
            if( strstr(token, str_cmp) != NULL ){
                sscanf(token, "#include < %s >", result);
                if(strchr(result, '>')  != NULL) result = rmchar(result, '>');
                Write("header.conf", result);
            }
        }
        token = strtok(NULL,"\n");
    }
}
//Ham thực hiện xóa ký tự > trong chuỗi
char* rmchar(char* input, char chr){
    char *result = (char*)malloc( strlen(input) * sizeof(char));
    int index = 0, size = 0;
    for(int i = 0; i < strlen(input); i++){
        if(input[i] == chr){
            continue;
        }
        result[index] = input[i];
        index++;
    }
    return result;
}

int isFileExist(char *filename){
    FILE* f = fopen(filename, "r");
    if(f == NULL) return 0;
    fclose(f);
    return 1;
}