// Selenium IDE output format for PLT Scheme
//
// Dave Gurnell and David Brooks, Untyped, April 2010
load("remoteControl.js");

this.name = "scheme-rc";

// String -> String
function hyphenate(str) {
	return str.replace(/[A-Z]/g,
	function(chr) {
		return "-" + chr.toLowerCase();
	});
}

function testMethodName(testName) {
	return "sel-" + hyphenate(testName);
}

function assertTrue(expression) {
	return "(check-true " + expression.toString() + ")";
}

function assertFalse(expression) {
	return "(check-false " + expression.toString() + ")";
}

function verify(statement) {
	return statement.toString();
}

function verifyTrue(expression) {
	return verify(assertTrue(expression));
}

function verifyFalse(expression) {
	return verify(assertFalse(expression));
}

function joinExpression(expression) {
	return "(join-expression " + expression.toString() + ")";
}

function assignToVariable(type, variable, expression) {
	return "(set! " + variable + " " + expression.toString() + ")";
}

function waitFor(expression) {
	return "(wait-for " + expression.toString() + ")";
}

function assertOrVerifyFailure(line, isAssert) {
	return "(assert-or-verify-failure " + line + " " + (isAssert ? "#t": "#f") + ")";
}

Equals.prototype.toString = function() {
	return "(equal? " + this.e2.toString() + " " + this.e1.toString() + ")";
};

Equals.prototype.assert = function() {
	return "(check-equal? " + this.e2.toString() + " " + this.e1.toString() + ")";
};

Equals.prototype.verify = function() {
	return "(check-equal? " + this.e2.toString() + " " + this.e1.toString() + ") #;(verify)";
};

NotEquals.prototype.toString = function() {
	return "(not (equal? " + this.e2.toString() + " " + this.e1.toString() + "))";
};

NotEquals.prototype.assert = function() {
	return "(check-not-equal? " + this.e2.toString() + " " + this.e1.toString() + ")";
};

NotEquals.prototype.verify = function() {
	return "(check-not-equal? " + this.e2.toString() + " " + this.e1.toString() + ") #;(verify)";
};

RegexpMatch.prototype.toString = function() {
	return "(regexp-match " + this.pattern + " " + this.expression + ")";
};

RegexpNotMatch.prototype.toString = function() {
	return "(not (regexp-match " + this.pattern + " " + this.expression + "))";
};

function pause(milliseconds) {
	return "(sleep (quotient " + milliseconds + " 1000))";
}

function echo(message) {
	return "(printf \"~a~n\" " + xlateArgument(message) + ")";
}

// String -> String
function formatString(str) {
	return "\"" + str.replace(/"/g, "\\\"") + "\"";
}

function statement(expression) {
	return expression.toString();
}

function array(value) {
	return "(list " + value.join(" ") + ")";
}

function nonBreakingSpace() {
	return "#\\space";
}

function formatComment(comment) {
	return comment.comment.replace(/.+/mg,
	function(str) {
		return "; " + str;
	});
}

// SeleniumTestCase String -> String
// Source code for SeleniumTestCase: chrome://selenium-ide/content/testCase.js
function format(testCase, name) {
	return "(test-case " + formatString(name) + formatCommands(testCase.commands) + ")";
}

// seleniumTestCase String -> void
function parse(testCase, source) {
	throw "Parsing not supported";
}

CallSelenium.prototype.toString = function() {
	var result =
		(this.negative ? "(not ": "") +
		"(sel-" + hyphenate(this.message);

	for (var i = 0; i < this.args.length; i++) {
		result += " " + this.args[i];
	}

	result += this.negative ? "))": ")";

	return result;
};
