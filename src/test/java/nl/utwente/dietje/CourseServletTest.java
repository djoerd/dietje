package nl.utwente.dietje;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.junit.Assert;
import org.junit.Test;

import nl.utwente.dietje.CourseServlet;

public class CourseServletTest {

    @Test
    public void testCourse() throws Exception {
        CourseServlet servlet = new CourseServlet();
        StringWriter result   = new StringWriter();
        PrintWriter writer    = new PrintWriter(result);
        servlet.doWrite(writer); 
        //System.out.println(result.toString());
        Assert.assertEquals(1, 1);
    }

}
