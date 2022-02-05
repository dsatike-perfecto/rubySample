require 'perfecto-reporting'
require 'appium_lib'
require 'selenium-webdriver'

desired_caps = {
        #  1. Replace <<cloud name>> with your perfecto cloud name (e.g. demo is the cloudName of demo.perfectomobile.com).
    appium_lib: {
        server_url: 'https://%s.perfectomobile.com/nexperience/perfectomobile/wd/hub' % "aetnahealth",  
    },
    caps: {
        #  2. Replace <<security token>> with your perfecto security token.
        securityToken: 'eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxYzMyMWM0OS03NjdlLTQ5ZWEtYTA0Yy0zZGY0N2MyOTU4MjcifQ.eyJpYXQiOjE2NDQwMTk4MzUsImp0aSI6ImFjNTBmOGI0LTMzZmEtNDEwNC04MGVkLTU1OTU4YjcxYjM2MiIsImlzcyI6Imh0dHBzOi8vYXV0aC5wZXJmZWN0b21vYmlsZS5jb20vYXV0aC9yZWFsbXMvYWV0bmFoZWFsdGgtcGVyZmVjdG9tb2JpbGUtY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRoLnBlcmZlY3RvbW9iaWxlLmNvbS9hdXRoL3JlYWxtcy9hZXRuYWhlYWx0aC1wZXJmZWN0b21vYmlsZS1jb20iLCJzdWIiOiI3NDMwMGEzMC0yZDk1LTQwZGYtOGVmZS0xMzNhMGEzZTJkNTQiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoib2ZmbGluZS10b2tlbi1nZW5lcmF0b3IiLCJub25jZSI6ImFkMjc5YTQzLWM4ZWUtNDVlNi04NjcyLWY3OTQ2MjgxZTZiMyIsInNlc3Npb25fc3RhdGUiOiI0NTY2MDA2Zi00NjlmLTRiMDYtYWEwMC1hYTliNWMzNjVhYTgiLCJzY29wZSI6Im9wZW5pZCBvZmZsaW5lX2FjY2VzcyJ9.sdUC9UplEEP12w1D5x9t3MBcqSjgAFDnt_vL0x6piV4',
        
        # 3. Set device capabilities.
        platformName: 'Android',
        model: 'Galaxy S.*',

        # Set other capabilities.
        browserName: 'mobileOS',
        useAppiumForWeb: true,
        openDeviceTimeout: 5
    }
}
# Initialize the Appium driver
@driver = Appium::Driver.new(desired_caps, true).start_driver

# Setting implicit wait
@driver.manage.timeouts.implicit_wait = 5

# Initialize Smart Reporting
if ENV["jobName"] != nil
    perfectoExecutionContext = PerfectoExecutionContext.new(PerfectoExecutionContext::PerfectoExecutionContextBuilder
    .withWebDriver(@driver).withJob(Job.new(ENV["jobName"], ENV["jobNumber"].to_i)).build)
else
    perfectoExecutionContext = PerfectoExecutionContext.new(PerfectoExecutionContext::PerfectoExecutionContextBuilder
            .withWebDriver(@driver).build)
end
@reportiumClient = PerfectoReportiumClient.new(perfectoExecutionContext)
tec = TestContext::TestContextBuilder.build()
@reportiumClient.testStart("Selenium Ruby Android Sample", tec)

begin
    timeout = 30
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    search = "perfectomobile"
    @reportiumClient.stepStart('Navigate to Google');
    @driver.get('https://www.google.com');
    @reportiumClient.stepEnd();

    @reportiumClient.stepStart('Search for ' + search);
    wait.until{ @driver.find_element(:name => 'q') }
    @driver.find_element(:name => 'q').send_keys(search)
    @driver.find_element(:name => 'q').send_keys:return
    @reportiumClient.stepEnd();

    @reportiumClient.stepStart('Verify Title');
    expectedText = "perfectomobile - Google Search";
    @reportiumClient.reportiumAssert(expectedText, @driver.title === expectedText)
    @reportiumClient.stepEnd();
            
    @reportiumClient.testStop(TestResultFactory.createSuccess(), tec)

rescue Exception => exception
    @exception = exception
    @reportiumClient.testStop(TestResultFactory.createFailure(@exception.exception.message, @exception.exception, nil), tec)
    raise exception
ensure
    # Prints the report url
     puts 'Report url - ' + @reportiumClient.getReportUrl
     
    #Quits the driver
    @driver.quit
    puts "Ruby Android Execution completed"
end
