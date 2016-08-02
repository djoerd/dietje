package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

    private static final long serialVersionUID = 1L;

    private List<Map<String, Object>> getAssignments(Connection connection, String courseID, String nickname) throws SQLException {
        List<Map<String, Object>> assignments  = new ArrayList<Map<String, Object>>();
        PreparedStatement statement = connection.prepareStatement(
          "SELECT a.aid as tag, a.title, a.description, s.grade FROM (SELECT * FROM assignment where cid = ?) as a LEFT OUTER JOIN (SELECT * FROM submits where sid = ?) as s ON a.aid = s.aid");
        statement.setString(1, courseID);
        statement.setString(2, nickname);
        ResultSet set = statement.executeQuery();
        while (set.next()) {
            Map<String, Object> assignment = new LinkedHashMap<String, Object>();
            assignment.put("tag", set.getString("tag"));
            assignment.put("title", set.getString("title"));
            String description = set.getString("description");
            if (description != null) { assignment.put("description", description); }
            Float grade = set.getFloat("grade"); 
            if (grade != null && grade > 0.0) { assignment.put("grade", grade); }
            assignments.add(assignment);
        }
        return assignments;
    }


    protected void doWrite(PrintWriter writer, String courseID, String nickname) throws IOException {
        DietjeDatabase database = null;
        Connection connection = null;
        try {
            database = new DietjeDatabase();
            connection = database.connect();
            Map<String, Object> resultMap = new LinkedHashMap<String, Object>();
            Map<String, Object> course = database.getCourse(connection, courseID);
            resultMap.put("course", course);
            Map<String, Object> student = database.getStudent(connection, courseID, nickname);
            resultMap.put("student", student);
            List<Map<String, Object>> assignments = getAssignments(connection, courseID, nickname);
            resultMap.put("assignments", assignments);
            writer.print(JSONValue.toJSONString(resultMap));
        } catch (SQLException e) {
            throw new IOException(e);
        }
        finally {
            try {
                connection.close();
                database.close();
            } catch (SQLException e) { }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {
        response.setContentType("application/json");
        doWrite(response.getWriter(), 
                request.getParameter("course"), 
                request.getParameter("nickname"));
    }
}
