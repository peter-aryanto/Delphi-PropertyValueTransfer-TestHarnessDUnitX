program PropertyValueTransferUsingRttiTest;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  Winapi.Windows,
  Test.DomainNameHere.Provider in 'DomainNameHere\Test.DomainNameHere.Provider.pas',
  Test.DomainNameHere.Helper in 'DomainNameHere\Test.DomainNameHere.Helper.pas';

{$R *.RES}

var
  GTestRunner: ITestRunner;
  GTestRunResult: IRunResults;
  GIsAllTestsPassed: Boolean = False;
begin
  ReportMemoryLeaksOnShutdown := IsDebuggerPresent;

  try
    GTestRunner := TDUnitX.CreateRunner;
    GTestRunner.AddLogger(TDUnitXConsoleLogger.Create);
    GTestRunner.AddLogger(TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile));
    GTestRunResult := GTestRunner.Execute;
    GIsAllTestsPassed := GTestRunResult.AllPassed;
  finally
    if not GIsAllTestsPassed then
      System.ExitCode := EXIT_ERRORS;

    if IsDebuggerPresent then
    begin
      System.Writeln;
      System.Write('Done.. press <Enter> to close.');
      System.Readln;
    end;
  end;
end.

