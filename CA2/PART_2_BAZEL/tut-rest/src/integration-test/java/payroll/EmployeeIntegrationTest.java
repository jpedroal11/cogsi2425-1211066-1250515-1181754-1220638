package payroll;

import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Integration test for Employee entity
 * Using JUnit 4 for Bazel compatibility
 */
public class EmployeeIntegrationTest {

    @Test
    public void testEmployeeCreation() {
        Employee employee = new Employee("John", "Doe", "Software Engineer");

        assertNotNull(employee);
        assertEquals("John", employee.getFirstName());
        assertEquals("Doe", employee.getLastName());
        assertEquals("Software Engineer", employee.getRole());
    }

    @Test
    public void testEmployeeNameConcatenation() {
        Employee employee = new Employee("Jane", "Smith", "Manager");

        String fullName = employee.getName();
        assertEquals("Jane Smith", fullName);
    }

    @Test
    public void testEmployeeSetName() {
        Employee employee = new Employee("Test", "User", "Tester");

        employee.setName("New Name");
        assertEquals("New", employee.getFirstName());
        assertEquals("Name", employee.getLastName());
    }
}
