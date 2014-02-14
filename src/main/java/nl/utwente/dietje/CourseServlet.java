package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import nl.utwente.dietje.DietjeDatabase;

public class CourseServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer) throws IOException {
        DietjeDatabase database = new DietjeDatabase();
        Connection connection = database.connect();
        try {
            PreparedStatement statement = connection.prepareStatement(
              "SELECT c.name, c.cid AS tag, count(DISTINCT s.sid) AS enrolled FROM course c, assignment a, submits s WHERE c.cid = a.cid AND a.aid= s.aid GROUP BY c.name, c.cid");
            ResultSet set = statement.executeQuery();
            while(set.next()) {
               String name = set.getString("name");
               String tag  = set.getString("tag");
               Integer enrolled = set.getInt("enrolled");
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        writer.print("{ \"courses\": [ { \"name\": \"Data and Information Assignments\", \"tag\": \"assign-di\", \"enrolled\": \"93\" }, { \"name\": \"Data and Information Project\", \"tag\": \"utwente-di\", \"enrolled\": \"19\" }, { \"name\": \"Information Retrieval\", \"tag\": \"utwente-ir\", \"enrolled\": \"0\" }, { \"name\": \"Managing Big Data\", \"tag\": \"utwente-mdb\", \"enrolled\": \"0\" }, { \"name\": \"XML and Databases\", \"tag\": \"utwente-xmldb\", \"enrolled\": \"0\" } ] }");

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                             response) throws ServletException, IOException {
        response.setContentType("application/json");
        doWrite(response.getWriter());
    }
}
