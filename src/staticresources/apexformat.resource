function format(testCase, name) {	
  apexcode = "global class NewTest extends testcloud1.SauceTest{\n" +
	
	"global class Step1 implements testcloud1.ITestStep { global boolean execute(testcloud1.ITest test, testcloud1.TestContext tc){\n" +
	"\tselenium1.DefaultSelenium s = test.getSelenium(tc.sessionId);\n" +	
    formatCommands(testCase.commands) +
	"\treturn false;\n" +
	"} }\n" +

	"static List<testcloud1.ITestStep> steps = new List<testcloud1.ITestStep>();\n" +
	"static\n" + 
	"{\n" +		
	"\tsteps.add(new Step1());\n" +
	"}\n\n" +
	
	"global NewTest(String os, String browser, String version) {\n" +
	"\tsuper(os, browser, version);\n" +
	"}\n\n" +

	"global override testcloud1.ITestStep getStep(integer step) {\n" +
	"\tif (step<=steps.size())\n" +
	"\t\treturn steps.get(step-1);\n" +
	"\telse\n" +
	"\t\treturn null;\n" +
	"}\n" +
	"}"; 
    return apexcode;
}

function formatCommands(commands) {
  var result = '';
  for (var i = 0; i < commands.length; i++) {
    var command = commands[i];
    if (command.type == 'command') {      
      result = result + qualifyCommand(command.command) + "('" + escapeSingleQuote(command.target) + "'" + 
      getCommandValue(command.value) + ");\n";
    }
  }
  return result;
}

/**
 * Given a line of apex parse selenium commands
 * @param source
 * @return
 */
function parseApex(source) {
	var commandLoadPattern = /s\.(\S+)\(\'(\S+)\'(,\s*\'(\S+)\')?\);/i;
	var commandLine;
	var doc = source;
	if(doc.length>0) {
		commandLine = commandLoadPattern.exec(doc);
	}
	return commandLine;
}

function parseApexSelenium(source) {	
	var commandLine = parseApex(source);
	if(commandLine)
		return makeCommand("command", commandLine[1], commandLine[2], commandLine[4]); // the 3rd element is the optional second parameter with command and all
	else
		return null;
}


function parse(testCase, source) {
	var doc = source;
	var commands = [];
	var commandFound = false;
	var header = '';
	var footer = '';
	var result;
	while (doc.length > 0) {
		line = /.*\n?/.exec(doc)[0];
		
		if ((result = parseApexSelenium(line)) != null) {
			commands.push(result);
			commandFound = true;
		} 
			
		doc = doc.substr(line.length);
	}
	if (commandFound) {
		testCase.header = header;
		testCase.footer = footer;
		testCase.setCommands(commands);
	} else {
		throw "no command found";
	}
}

function makeCommand(type, myCommand, target, myvalue) {
	  var command = new Command();
	  command.command = myCommand;
	  command.target = target;
	  command.value = myvalue;
	  return command;
}

function qualifyCommand(commandName) {
	return "\t" + DEFAULT_SELENIUM_VARIABLE + "." + commandName;
}

function escapeSingleQuote(value) {
   return value.replace(/\'/g,"\\\'");
}

function getCommandValue(value) {
	return value ? ", '" + escapeSingleQuote(value) + "'" : "";
}

DEFAULT_SELENIUM_VARIABLE = "s";