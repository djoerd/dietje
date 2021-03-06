package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONValue;
import nl.utwente.dietje.DietjeDatabase;


public class FeedbackServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doWrite(PrintWriter writer,  String courseID, String nickname, String assignID) throws IOException {
        DietjeDatabase database = null;
        Connection connection = null;
        Map<String, Object> feedback  = new LinkedHashMap<String, Object>();
        try {
            database = new DietjeDatabase();
            connection = database.connect();
            PreparedStatement statement = connection.prepareStatement(
              "SELECT s.aid as tag, a.title, a.description, s.grade, s.attempts, s.feedback as motivation FROM submits s, assignment a WHERE s.aid = a.aid AND a.cid = ? AND s.sid = ? AND s.aid = ?");
            statement.setString(1, courseID);
            statement.setString(2, nickname);
            statement.setString(3, assignID);
            ResultSet set = statement.executeQuery();
            if (set.next()) {
                feedback.put("tag", set.getString("tag"));
                String description = set.getString("title");
                if (description != null) { feedback.put("description", description); }
                Float grade = set.getFloat("grade");
                if (grade != null && grade > 0.0) { feedback.put("grade", grade); }
                feedback.put("attempts", set.getInt("attempts"));
                String motivation = set.getString("motivation");
                if (motivation != null) { 
                  motivation = motivation.replace("<", "&lt;").replace(">", "&gt;");
                  feedback.put("motivation", motivation); 
                }
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        finally {
            try {
                connection.close();
                database.close();
            } catch (SQLException e) { }
        }
        Map<String, Object> resultMap = new LinkedHashMap<String, Object>();
        resultMap.put("feedback", feedback);
        writer.print(JSONValue.toJSONString(resultMap));
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter(),
                request.getParameter("course"),
                request.getParameter("nickname"),
                request.getParameter("assignment"));
    }
}
