package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONValue;
import nl.utwente.dietje.DietjeDatabase;


public class AssignmentServlet extends HttpServlet {

    private List getAssignments(Connection connection, String courseID, String nickname) throws IOException {
        List assignments  = new ArrayList<Object>();
        try {
            PreparedStatement statement = connection.prepareStatement(
              "SELECT a.aid as tag, a.title, a.description, s.grade FROM (SELECT * FROM assignment where cid = ?) as a LEFT OUTER JOIN (SELECT * FROM submits where sid = ?) as s ON a.aid = s.aid");
            statement.setString(1, courseID);
            statement.setString(2, nickname);
            ResultSet set = statement.executeQuery();
            while (set.next()) {
                Map assignment = new LinkedHashMap<String, Object>();
                assignment.put("tag", set.getString("tag"));
                assignment.put("title", set.getString("title"));
                String description = set.getString("description");
                if (description != null) { assignment.put("description", description); }
                Float grade = set.getFloat("grade"); 
                if (grade != null && grade > 0.0) { assignment.put("grade", grade); }
                assignments.add(assignment);
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        return assignments;
    }


    protected void doWrite(PrintWriter writer, String courseID, String nickname) throws IOException {
        DietjeDatabase database = new DietjeDatabase();
        Connection connection = database.connect();
        Map resultMap = new LinkedHashMap<String, Object>();
        Map course = database.getCourse(connection, courseID);
        resultMap.put("course", course);
        Map student = database.getStudent(connection, courseID, nickname);
        resultMap.put("student", student);
        List assignments = getAssignments(connection, courseID, nickname);
        resultMap.put("assignments", assignments);
        writer.print(JSONValue.toJSONString(resultMap));
        try {
            connection.close();
            database.close();
        } catch (SQLException e) { } 
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {
        response.setContentType("application/json");
        doWrite(response.getWriter(), 
                request.getParameter("course"), 
                request.getParameter("nickname"));
    }
}
