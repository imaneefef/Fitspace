import java.io.*;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    private String ip;
    private int port;
    private Socket socket;
    private PrintWriter writer;
    private BufferedReader reader;
    private Scanner scanner;

    // Constructeur de la classe Client
    public Client(String ip, int port) {
        this.ip = ip;
        this.port = port;
        this.scanner = new Scanner(System.in);
    }

    // Fonction pour se connecter au socket
    public void connect() throws IOException {
        this.socket = new Socket(ip, port);
        this.writer = new PrintWriter(socket.getOutputStream(), true);
        this.reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        System.out.println("Connecté au serveur sur " + ip + ":" + port);
    }

    // Fonction pour se déconnecter du socket
    public void disconnect(String message) throws IOException {
        if (socket != null && !socket.isClosed()) {
            socket.close();
        }
        if (reader != null) {
            reader.close();
        }
        if (writer != null) {
            writer.close();
        }
        if (scanner != null) {
            scanner.close();
        }
        System.out.println(message);
    }

    // Fonction pour vérifier le scanner
    public void verifyScanner() throws IOException {
        // Entrer l'ID du scanner
        System.out.print("Entrez l'ID du scanner : ");
        String idScanner = scanner.nextLine();
        writer.println(idScanner);

        // Vérifier la réponse du serveur
        String response = reader.readLine();
        boolean isValid = Boolean.parseBoolean(response);
        if (isValid) {
            System.out.println("Le scanner " + idScanner + " est valide");
        } else {
            System.out.println("Le scanner " + idScanner + " est invalide");
            disconnect("Problème d'identification du Scanner");
        }
    }

    // Méthode pour envoyer l'identifiant du QR code
    public void sendQrCodeInfo() throws IOException {
        System.out.print("Entrez l'ID du QR code : ");
        String idQrCode = scanner.nextLine();

        // Envoie de l'ID du QR code au serveur
        writer.println(idQrCode);
        System.out.println("ID du QR Code envoyé : " + idQrCode);

        // Vérifier la réponse du serveur
        String response = reader.readLine();
        boolean isValid = Boolean.parseBoolean(response);

        if (isValid) {
            System.out.println("Le QR Code: " + idQrCode + " est valide");
        } else {
            System.out.println("Le QR Code: " + idQrCode + " est invalide");
            disconnect("Problème de validité du QR Code");
        }
    }

    public void displayUserInfo() throws IOException{
        // on recupère les informations de l'utilisateur (prenom + nom)
        String prenom = reader.readLine();
        String nom = reader.readLine();

        if (prenom != null && nom != null){
            System.out.println("Bienvenue dans notre Salle de Sport "+prenom+" "+nom+" !!!");
        }
        
    }
}
