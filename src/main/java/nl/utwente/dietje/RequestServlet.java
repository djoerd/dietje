package nl.utwente.dietje;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

public class RequestServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) {
        writer.print("{ \"message\": \"Prof. Dietje will grade your assignment in 20 minutes.\" } ");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter());
    }
}
