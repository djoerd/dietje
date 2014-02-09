package nl.utwente.dietje;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.junit.Assert;
import org.junit.Test;

import nl.utwente.dietje.CourseServlet;

public class StudentServletTest {

    @Test
    public void testStudent() throws Exception {
        StudentServlet servlet = new StudentServlet();
        Assert.assertEquals(1, 1);
    }

}
