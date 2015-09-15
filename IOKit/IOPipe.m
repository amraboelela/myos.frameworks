/*
 Copyright © 2014-2015 myOS Group.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 Lesser General Public License for more details.
 
 Contributor(s):
 Amr Aboelela <amraboelela@gmail.com>
 */

#import <stdio.h>
#import <unistd.h>
#import <IOKit/IOKit.h>

#define kEndOfMessage   0
#define kDataSize       512

static int _pipeRead;
static int _pipeWrite;

#pragma mark - Static functions

static void _IOPipeWriteEndOfMessage()
{
    DLog();
    char aChar=kEndOfMessage;
    write(_pipeWrite,&aChar,1);
}

static void _IOPipeWriteEndOfMessageWithPipe(int writePipe)
{
    DLog();
    char aChar=kEndOfMessage;
    write(writePipe,&aChar,1);
}

#pragma mark - Public functions

void IOPipeSetPipes(int pipeRead, int pipeWrite)
{
    DLog(@"pipeRead: %d, pipeWrite: %d", pipeRead, pipeWrite);
    _pipeRead = pipeRead;
    _pipeWrite = pipeWrite;
}

void IOPipeWriteLine(NSString *message)
{
    NSString *line = [NSString stringWithFormat:@"%@\n", message];
    write(_pipeWrite, [line cString], line.length);
}

NSString *IOPipeReadLine(int file)
{
    DLog();
    return _NSFileHandleReadLine(file);
}

void IOPipeWriteMessage(int message, BOOL withEnd)
{
    DLog(@"message: %d", message);
    char aChar=message;
    write(_pipeWrite,&aChar,1);
    if (withEnd) {
        _IOPipeWriteEndOfMessage();
    }
}

void IOPipeWriteMessageWithPipe(int message, BOOL withEnd, int pipeWrite)
{
    DLog(@"message: %d", message);
    char aChar=message;
    write(pipeWrite,&aChar,1);
    if (withEnd) {
        _IOPipeWriteEndOfMessageWithPipe(pipeWrite);
    }
}

int IOPipeReadMessage()
{
    char message;
    DLog(@"_pipeRead: %d", _pipeRead);
    read(_pipeRead, &message, 1);
    return message;
}

int IOPipeReadMessageWithPipe(int pipeRead)
{
    char message;
    DLog(@"_pipeRead: %d", _pipeRead);
    read(pipeRead, &message, 1);
    return message;
}

void IOPipeWriteCharString(NSString *aString)
{
    //_IOPipeWriteMessage(pipe, IOPipeMessageTypeCharString);
    DLog(@"[aString cString]: %s", [aString cString]);
    write(_pipeWrite,[aString cString],aString.length);
    char aChar=0;
    write(_pipeWrite,&aChar,1); // end of string
}

NSString *IOPipeReadCharString()
{
    char aChar = ' ';
    NSMutableString *aString = [[NSMutableString alloc] init];
    DLog(@"_pipeRead: %d", _pipeRead);
    while (aChar != 0) {
        read(_pipeRead, &aChar, 1);
        //DLog(@"aChar: %c", aChar);
        if (aChar != kEndOfMessage) {
            [aString appendFormat:@"%c", aChar];
        }
    }
    return [aString autorelease];
}

void IOPipeWriteIntWithPipe(int value, int pipeWrite)
{
    write(pipeWrite, &value, sizeof(int));
}

void IOPipeWriteInt(int value)
{
    write(_pipeWrite, &value, sizeof(int));
}

int IOPipeReadInt()
{
    int value;
    read(_pipeRead, &value, sizeof(int));
    return value;
}

int IOPipeReadIntWithPipe(int pipeRead)
{
    int value;
    read(pipeRead, &value, sizeof(int));
    return value;
}

void IOPipeWriteFloat(float value)
{
    write(_pipeWrite, &value, sizeof(float));
}

void IOPipeWriteFloatWithPipe(float value, int pipeWrite)
{
    write(pipeWrite, &value, sizeof(float));
}

float IOPipeReadFloat()
{
    float value;
    read(_pipeRead, &value, sizeof(float));
    return value;
}

float IOPipeReadFloatWithPipe(int readPipe)
{
    float value;
    read(readPipe, &value, sizeof(float));
    return value;
}

void IOPipeWriteData(void *data, int size)
{
    write(_pipeWrite, data, size);
}

void IOPipeWriteDataWithPipe(void *data, int size, int pipeWrite)
{
    write(pipeWrite, data, size);
}

void IOPipeReadData(void *data, int size)
{
    read(_pipeRead, data, size);
}

void IOPipeReadDataWithPipe(void *data, int size, int readPipe)
{
    read(readPipe, data, size);
}

int IOPipeClosePipes()
{
    DLog(@"IOPipeClosePipes");
    //int pipeWrite = _mlPipe1[1];
    //int pipeRead = _mlPipe2[0];
    close(_pipeRead);
    close(_pipeWrite);
}

NSString *IOPipeRunCommand(NSString *command, BOOL usingPipe)
{
    const char *cCommand = [command cString];
    //cCommand = "/data/app/HelloWorld-c";
    
    // Execute a process listing
    //sprintf(command, "ps aux wwwf");
    
    // Setup our pipe for reading and execute our command.
    if (usingPipe) {
        FILE *pf = popen(cCommand, "r");
        if(!pf){
            //DLog(@"Could not open pipe for output.");
            return @"Could not open pipe for output.";
        }
        NSMutableString *commandOutput = [[NSMutableString alloc] init];
        char data[kDataSize];
        // Grab data from process execution
        while (fgets(data, kDataSize , pf)) {
            // Print grabbed data to the screen.
            //NSLog(@"data: %s", data);
            [commandOutput appendString:[NSString stringWithFormat:@"%s", data]];
        }
        pclose(pf);
        return [commandOutput autorelease];
    } else {
        system(cCommand);
        return nil;
    }
}
