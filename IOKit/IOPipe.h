/*
 Copyright © 2014-2016 myOS Group.
 
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

typedef enum {
    NativePipeMessageEndOfMessage,
} NativePipeMessage;

typedef enum {
    ParentPipeMessageEndOfMessage,
    ParentPipeMessageInt,
    ParentPipeMessageCharString,
    ParentPipeMessageChildIsReady,
    ParentPipeMessageMoveApplicationToTop,
    ParentPipeMessageTerminateApp,
} ParentPipeMessage;

typedef enum {
    ChildPipeMessageEndOfMessage,
    ChildPipeMessageInt,
    ChildPipeMessageCharString,
    ChildPipeMessageScreenSize,
    ChildPipeMessageData,
    ChildPipeMessageEventActionDown,
    ChildPipeMessageEventActionMoved,
    ChildPipeMessageEventActionUp,
    ChildPipeMessageWillEnterBackground,
    ChildPipeMessageTerminateApp,
} ChildPipeMessage;

void IOPipeSetPipes(int pipeRead, int pipeWrite);
NSString *IOPipeReadLine();
void IOPipeWriteLine(NSString *message);
void IOPipeWriteMessage(int message, BOOL withEnd);
void IOPipeWriteMessageWithPipe(int message, BOOL withEnd, int pipeWrite);
int IOPipeReadMessage();
int IOPipeReadMessageWithPipe(int pipeRead);
void IOPipeWriteCharString(NSString *aString);
NSString *IOPipeReadCharString();
void IOPipeWriteInt(int value);
void IOPipeWriteIntWithPipe(int value, int pipeWrite);
int IOPipeReadInt();
int IOPipeReadIntWithPipe(int pipeRead);
void IOPipeWriteFloat(float value);
void IOPipeWriteFloatWithPipe(float value, int pipeWrite);
float IOPipeReadFloat();
float IOPipeReadFloatWithPipe(int pipeRead);
void IOPipeWriteData(void *data, int size);
void IOPipeWriteDataWithPipe(void *data, int size, int pipeWrite);
void IOPipeReadData(void *data, int size);
void IOPipeReadDataWithPipe(void *data, int size, int pipeRead);
int IOPipeClosePipes();
NSString *IOPipeRunCommand(NSString *command, BOOL usingPipe);
