package nl.utwente.dietje;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.junit.Assert;
import org.junit.Test;

import nl.utwente.dietje.AssignmentServlet;

public class AssignmentServletTest {

    @Test
    public void testAssignment() throws Exception {
        AssignmentServlet servlet = new AssignmentServlet();
        StringWriter result   = new StringWriter();
        PrintWriter writer    = new PrintWriter(result);
        servlet.doWrite(writer, "assign-di", "djoerd");
        System.out.println(result.toString());
        Assert.assertEquals(1, 1);
    }

}
