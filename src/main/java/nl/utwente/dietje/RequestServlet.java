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


public class RequestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private Map<String, Object> getSubmitted(Connection connection, String courseID, String nickname, String assignID) throws SQLException {
        Map<String, Object> submitted = new LinkedHashMap<String, Object>();
        PreparedStatement statement = connection.prepareStatement(
         "SELECT request_date, feedback_date, attempts FROM submits WHERE sid = ? AND aid = ? AND aid IN (SELECT aid FROM assignment WHERE cid = ?);");
        statement.setString(1, nickname);
        statement.setString(2, assignID);
        statement.setString(3, courseID);
        ResultSet set = statement.executeQuery();
        if (set.next()) {
            submitted.put("request_date", set.getString("request_date"));
            String feedback_date = set.getString("feedback_date");
            if (feedback_date != null) { submitted.put("feedback_date", feedback_date); }
            submitted.put("attempts", set.getInt("attempts"));
        }
        return submitted;
    }

    private void insertSubmitted(Connection connection, String nickname, String assignID) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(
          "INSERT INTO submits (sid, aid, request_date, attempts) VALUES (?, ?, NOW(), 1)"
        );
        statement.setString(1, nickname);
        statement.setString(2, assignID);
        statement.executeUpdate();
    }

    private void updateSubmitted(Connection connection, 
            String nickname, String assignID, String courseID) throws SQLException {
        PreparedStatement statement = connection.prepareStatement(
            "UPDATE submits SET request_date = NOW(), attempts = attempts + 1  WHERE sid = ? AND aid = ? AND aid IN (SELECT aid FROM assignment WHERE cid = ?)"
        );
        statement.setString(1, nickname);
        statement.setString(2, assignID);
        statement.setString(3, courseID);
        statement.executeUpdate();
    }

    protected void doWrite(PrintWriter writer, String courseID, String nickname, String assignID) throws IOException {
        DietjeDatabase database = null;
        Connection connection = null;
        String alert = "";
        try {
            database = new DietjeDatabase();
            connection = database.connect();
            Map<String, Object> submitted = getSubmitted(connection, courseID, nickname, assignID);
            if (!submitted.containsKey("attempts")) {
                alert += "5 minutes to grade your assignment.";
                insertSubmitted(connection, nickname, assignID);
            }
            else {
                Integer attempts = (Integer) submitted.get("attempts");
                String request_date = (String) submitted.get("request_date");
                String feedback_date = (String) submitted.get("feedback_date");
                if (feedback_date != null && feedback_date.compareTo(request_date) > 0) {
                    attempts += 1;
                    updateSubmitted(connection, nickname, assignID, courseID);
                }
                else {
                    alert += "You requested a new grade at: " + request_date.substring(0,16) + " h. ";
                }
                alert += "Prof. Dietje will take about " + 
                         Integer.toString(attempts * 5) + " minutes to grade your work. ";
            } 
        } catch (SQLException e) {
            alert = "Prof. Dietje is unable to grade your exam at the moment. Please try again later.";
        } finally {
            try {
                connection.close();
                database.close();
            } catch (SQLException e) { }
        }
        Map<String, String> resultMap = new LinkedHashMap<String, String>();
        resultMap.put("message", alert);
        writer.print(JSONValue.toJSONString(resultMap));
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse 
                           response) throws ServletException, IOException {

        response.setContentType("application/json");
        doWrite(response.getWriter(),
                request.getParameter("course"),
                request.getParameter("nickname"),
                request.getParameter("assignment"));
    }
}
