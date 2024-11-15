module command_handler;

import std.process;
import std.stdio;
import std.string;

// punk's signature.
pragma(msg, "punked out!");

class ExitException : Exception {
    int status;
    this(int _status=0, string file=__FILE__, size_t
        line=__LINE__)
    {
        super("Program exit", file, line);
        status = _status;
    }
}

alias functionPointerType = void function();
struct CommandStruct 
{
    immutable string name;
    functionPointerType execute;
    immutable string help;
}

// Add additional commands to `commands` array.
// e.g: "ping": CommandStruct("ping", &nameOfFunction, "Description of function").
const CommandStruct[string] commands = 
[
    "version": CommandStruct("version", &cmdVersion, "Display version number."),
    "flashTest": CommandStruct("flashTest", &cmdFlashTest, "Run a flash test."),
    "help": CommandStruct("help", &cmdHelp, "Displays help menu."),
    "exit": CommandStruct("exit", &cmdExit, "Exit the CLI program."),
    "ping": CommandStruct("ping", &cmdPing, "Ping pong!"),
    "clear": CommandStruct("clear", &cmdClearScrn, "Clears the screen.")
];

// This is where you define & create the functions for your commands.
// They will be the functions executed via `functionPointerType`.
void cmdVersion() {writeln("Version 0.0.2");}
void cmdFlashTest() {writeln("Flash test");}
void cmdExit() {throw new ExitException(0);}
void cmdPing() {writeln("pong!");}
void cmdClearScrn() { spawnShell(`cls`).wait; }

void cmdHelp() {
    writeln("\nAvailable Commands:");
    writeln("Name            Description");
    writeln("------------------------------------------------------");

    foreach (name, command; commands) {
        auto spaces = 16 - command.name.length;
        if (spaces < 1) spaces = 1;

        string spaceStr = "";
        for (int i = 0; i < spaces; i++)
        {
            spaceStr ~= " ";
        }
        writefln("%s%s%s", command.name, spaceStr, command.help);
    }
}

// Handling commands
void cmdHandler(string cmd)
{
    if (const CommandStruct* cmdPtr = cmd in commands)
    { 
        cmdPtr.execute();
    }
    else 
    {
        writeln("No matching command found.");
        auto suggestions = autoComplete(cmd);
        if (suggestions.length > 0)
        {
            writeln("Did you mean: ");
            foreach (suggestion; suggestions)
            {
                writeln(" - ", suggestion);
            }
        }
    }
}

string[] autoComplete(string partial)
{
    string[] matches;
    foreach (command; commands)
    {
        if (command.name.startsWith(partial))
        {
            matches ~= command.name;
        }
    }
    return matches;
}

void runPrompt()
{
    while (true)
    {
        // Edit this to change prompt.
        write("(\033[4mcmd-handler\033[0m) > "); 
        string cmd = strip(stdin.readln());
        cmdHandler(cmd);
    }
}

void main() 
{
    runPrompt();
}