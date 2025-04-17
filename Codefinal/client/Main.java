import java.io.IOException;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        String ip = "127.0.0.1";
        System.out.println("entrez le numero de port :");
        Scanner sc = new Scanner(System.in);
        int port = sc.nextInt();

        Client client = new Client(ip, port);
        try {
            client.connect();
            client.verifyScanner();
            client.sendQrCodeInfo();
            client.displayUserInfo();
            System.out.println("Vous Pouvez Entrer");
        } catch (IOException ex) {
            System.out.println("Erreur : " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            try {
                client.disconnect("Fermeture de la connexion");
                sc.close();
            } catch (IOException ex) {
                System.out.println("Erreur lors de la fermeture : " + ex.getMessage());
            }
        }
    }
}

