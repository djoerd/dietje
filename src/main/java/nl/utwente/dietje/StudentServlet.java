package nl.utwente.dietje;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

public class StudentServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) {
        writer.print("{ \"course\": { \"name\": \"Data and Information\", \"enrolled\": \"93\" }, \"students\": [ { \"nickname\": \"lferreirapires\", \"realname\": \"Luis Ferreira Pires\", \"progress\": \"60\", \"grade\": \"8.5\" }, { \"nickname\": \"djoerd\", \"realname\": \"Djoerd Hiemstra\", \"progress\": \"60\", \"grade\": \"7.2\" }, { \"nickname\": \"drunkenpirate02\", \"progress\": \"50\", \"grade\": \"9.2\" }, { \"nickname\": \"dutchprostudent54\", \"realname\": \"Jan Jansen\", \"progress\": \"40\", \"grade\": \"6.5\" }, { \"nickname\": \"pietje01\", \"progress\": \"40\", \"grade\": \"6.4\" }, { \"nickname\": \"johnsmith\", \"realname\": \"John Smith\", \"progress\": \"40\", \"grade\": \"5.7\" }, { \"nickname\": \"programmingrocks\", \"realname\": \"Test Test\" } ] } ");
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter());
    }
}
