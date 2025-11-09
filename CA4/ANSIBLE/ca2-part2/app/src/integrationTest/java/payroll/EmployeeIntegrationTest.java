package payroll;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;

import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
public class EmployeeIntegrationTest {

    @Autowired
    private ApplicationContext applicationContext;

    @Test
    public void contextLoads() {
        // Verify Spring context loads
        assertNotNull(applicationContext);
    }

    @Test
    public void mainApplicationBeanExists() {
        // Verify the main application class is in the context
        PayrollApplication mainApp = applicationContext.getBean(PayrollApplication.class);
        assertNotNull(mainApp);
    }
}