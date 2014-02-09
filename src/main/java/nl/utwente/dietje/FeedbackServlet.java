package nl.utwente.dietje;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

public class FeedbackServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) {
        writer.print("{ \"feedback\": { \"tag\": \"assignment01\", \"title\": \"Assignment 1\", \"description\": \"Getting to know git and SQL\", \"message\": \"You requested a new grade. Prof. Dietje will grade your assignment in 20 minutes.\", \"grade\": \"9.3\", \"motivation\": \"Prof. Dietje says: Welcome lferreirapires.\\nI will grade your results for 'practicum01'.\" } } ");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter());
    }
}
