global class TestSauceForce extends SauceTest{
  
  static List<ITestStep> steps = new List<ITestStep>();

  public TestSauceForce(String os, String browser, String version) {
      super(os, browser, version);
  }
  
  global override ITestStep getStep(integer step) {
      return null;
  }
}