package nl.utwente.dietje;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

public class CourseServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) {
        writer.print("{ \"courses\": [ { \"name\": \"Data and Information Assignments\", \"tag\": \"assign-di\", \"enrolled\": \"93\" }, { \"name\": \"Data and Information Project\", \"tag\": \"utwente-di\", \"enrolled\": \"19\" }, { \"name\": \"Information Retrieval\", \"tag\": \"utwente-ir\", \"enrolled\": \"0\" }, { \"name\": \"Managing Big Data\", \"tag\": \"utwente-mdb\", \"enrolled\": \"0\" }, { \"name\": \"XML and Databases\", \"tag\": \"utwente-xmldb\", \"enrolled\": \"0\" } ] }");

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter());
    }
}
