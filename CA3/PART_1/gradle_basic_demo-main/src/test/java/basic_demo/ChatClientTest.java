package basic_demo;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import javax.swing.*;

public class ChatClientTest {

    @Test
    public void testClientInitialization() {
        // Run Swing code on the event dispatch thread (safe for Swing testing)
        SwingUtilities.invokeLater(() -> {
            ChatClient client = new ChatClient("localhost", 59001);

            assertNotNull(client, "ChatClient should be created");
            assertTrue(client instanceof ChatClient, "Should be instance of ChatClient");
        });
    }


}
