import com.ibm.mq.*;                           // Include the WebSphere MQ classes for Java package
import com.ibm.mq.constants.CMQC;


public class QDepth
{
  private String qManager;                     // define name of queue
                                               // manager to connect to.
  private MQQueueManager qMgr;                 // define a queue manager
                                               // object
  public static void main(String[] args) {
    new QDepth();
  }

  public QDepth() {
    try {

      qManager                = System.getProperty("QM")      == null ? "QM"             : System.getProperty("QM");

      MQEnvironment.hostname  = System.getProperty("Server")  == null ? "localhost"      : System.getProperty("Server");
      MQEnvironment.port      = System.getProperty("Port")    == null ? 1414             : Integer.parseInt(System.getProperty("Port"));
      MQEnvironment.channel   = System.getProperty("Channel") == null ? "SYSTEM.CHANNEL" : System.getProperty("Channel");

      // Create a connection to the queue manager

      if ("true".equalsIgnoreCase(System.getProperty("Verbose"))) {
        System.out.println("Connecting to Queue Manager: " + qManager + " at " + MQEnvironment.hostname + ":" + MQEnvironment.port + " with channel: '" + MQEnvironment.channel + "'");
      }

      qMgr = new MQQueueManager(qManager);

      // Set up the options on the queue we wish to open...
      // Note. All WebSphere MQ Options are prefixed with MQC in Java.

      int openOptions = CMQC.MQOO_INQUIRE |
                        CMQC.MQOO_FAIL_IF_QUIESCING |
                        CMQC.MQOO_INPUT_SHARED;

      // Now specify the queue that we wish to open,
      // and the open options...

      String queueName = System.getProperty("Queue") == null ? "QUEUE" : System.getProperty("Queue");

      if ("true".equalsIgnoreCase(System.getProperty("Verbose"))) {
        System.out.println("Getting message count in queue: " + queueName);
      }

      MQQueue queue = qMgr.accessQueue(queueName, openOptions);
      int qSize = queue.getCurrentDepth();
      System.out.println(queueName + ":" + qSize);

      // Close the queue...
      queue.close();
      // Disconnect from the queue manager

      qMgr.disconnect();
    }
      // If an error has occurred in the above, try to identify what went wrong
      // Was it a WebSphere MQ error?
    catch (MQException ex)
    {
      System.out.println("A WebSphere MQ error occurred : Completion code " +
                         ex.completionCode + " Reason code " + ex.reasonCode);
    }
  }
}
