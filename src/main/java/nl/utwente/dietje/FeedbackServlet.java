package nl.utwente.dietje;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONValue;
import nl.utwente.dietje.DietjeDatabase;


public class FeedbackServlet extends HttpServlet {

    protected void doWrite(PrintWriter writer,  String courseID, String nickname, String assignID) throws IOException {
        DietjeDatabase database = new DietjeDatabase();
        Connection connection = database.connect();
        Map feedback  = new LinkedHashMap<String, Object>();
        try {
            PreparedStatement statement = connection.prepareStatement(
              "SELECT s.aid as tag, a.title, a.description, s.grade, s.feedback as motivation FROM submits s, assignment a WHERE s.aid = a.aid AND a.cid = ? AND s.sid = ? AND s.aid = ?");
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
                String motivation = set.getString("motivation");
                if (motivation != null) { feedback.put("motivation", motivation); }
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
        Map resultMap = new LinkedHashMap<String, Object>();
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
