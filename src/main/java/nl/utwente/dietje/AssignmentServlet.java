package nl.utwente.dietje;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

public class AssignmentServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) {
        writer.print("{ \"course\": { \"name\": \"Data and Information Assignments\" }, \"student\": { \"nickname\": \"lferreirapires\", \"realname\": \"Luis Ferreira Pires\", \"progress\": \"95\", \"grade\": \"8.1\" }, \"assignments\": [ { \"tag\": \"assignment01\", \"title\": \"Assignment 1\", \"description\": \"Getting to know git and SQL\", \"grade\": \"7.1\" }, { \"tag\": \"assignment02\", \"title\": \"Assignment 2\", \"grade\": \"9.0\" }, { \"tag\": \"assignment03\", \"title\": \"Assignment 3\" }, { \"tag\": \"assignment04\", \"title\": \"Assignment 4\" }, { \"tag\": \"assignment05\", \"title\": \"Assignment 5\" }, { \"tag\": \"assignment06\", \"title\": \"Assignment 6\" }, { \"tag\": \"assignment07\", \"title\": \"Assignment 7\" }, { \"tag\": \"assignment08\", \"title\": \"Assignment 8\" }, { \"tag\": \"assignment09\", \"title\": \"Assignment 9\" } ] } ");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter());
    }
}
