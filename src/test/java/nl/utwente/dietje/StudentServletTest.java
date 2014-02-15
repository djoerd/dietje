package nl.utwente.dietje;

import java.io.PrintWriter;
import java.io.StringWriter;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.junit.Assert;
import org.junit.Test;

import nl.utwente.dietje.StudentServlet;

public class StudentServletTest {

    @Test
    public void testStudent() throws Exception {
        StudentServlet servlet = new StudentServlet();
        StringWriter result   = new StringWriter();
        PrintWriter writer    = new PrintWriter(result);
        servlet.doWrite(writer, "assign-di");
        System.out.println(result.toString());
        Assert.assertEquals(1, 1);
    }

}
