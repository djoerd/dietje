package nl.utwente.dietje;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.junit.Assert;
import org.junit.Test;

import nl.utwente.dietje.FeedbackServlet;

public class FeedbackServletTest {

    @Test
    public void testFeedback() throws Exception {
        FeedbackServlet servlet = new FeedbackServlet();
        StringWriter result   = new StringWriter();
        PrintWriter writer    = new PrintWriter(result);
        servlet.doWrite(writer, "assign-di", "djoerd", "assign01");
        System.out.println(result.toString());
        Assert.assertEquals(1, 1);
    }

}
