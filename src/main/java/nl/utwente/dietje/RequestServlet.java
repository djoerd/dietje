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


public class RequestServlet extends HttpServlet {

    private Map getSubmitted(Connection connection, String courseID, String nickname, String assignID) throws SQLException {
        Map submitted = new LinkedHashMap<String, Object>();
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
        DietjeDatabase database = new DietjeDatabase();
        Connection connection = database.connect();
        String alert = "Prof Dietje will take about ";
        try {
            Map submitted = getSubmitted(connection, courseID, nickname, assignID);
            if (!submitted.containsKey("attempts")) {
                alert += "5 minutes to grade your assignment.";
                insertSubmitted(connection, nickname, assignID);
            }
            else {
                alert += Integer.toString((Integer) submitted.get("attempts") *5) + " minutes to grade your work.";
                String request_date = (String) submitted.get("request_date");
                String feedback_date = (String) submitted.get("feedback_date");
                if (feedback_date != null && feedback_date.compareTo(request_date) > 0) {
                    updateSubmitted(connection, nickname, assignID, courseID);
                }
                else {
                    alert += " You requested a new grade at " + request_date;
                }
            } 
        } catch (SQLException e) {
            alert = "Prof. Dietje is unable to grade your exam at the moment. Please try again later.";
        } finally {
            database.close();
        }

        Map resultMap = new LinkedHashMap<String, String>();
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
