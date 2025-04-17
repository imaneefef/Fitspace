import psycopg
import configparser
import socket
from datetime import datetime

connection = None

def connect_db():
    # On créer un variable global pour la connexion afin de ne se connecter qu'une fois à la BD
    global connection
    # On parse et on lit le fichier config-db.ini qui contient les infos nécessaires pour se 
    # connecter à notre BD (host, port, nom, utilisateur, mot de passe)
    config = configparser.ConfigParser()
    config.read('config-db.ini')
    db_params = config['database']
    try:
        # On se connect à la BD avec psycopg (librairie de python)
        connection = psycopg.connect(
            host=db_params['host'],
            port=db_params['port'],
            dbname=db_params['dbname'],
            user=db_params['user'],
            password=db_params['password']
        )
        print(f"connecté à la base de donnée")
    except Exception as e:
        print(f"Erreur lors de la connexion à la base de données : {e}")
        return None

# Fonction pour recevoir un message du client
def receive_message(client_socket):
    data = client_socket.recv(1024)
    return data.decode('utf-8').strip()

def verify_scanner(scanner_id):
    try:
        cursor = connection.cursor()
        cursor.execute("SELECT id_salle_sport FROM scanner WHERE id_scanner = %s", (scanner_id,))
        result = cursor.fetchone()
        if(result is not None):
            return result[0]
        else:
            return False
    except Exception as e:
        print(f"Problème de connexion : {e}")
        return False


# Fonction pour vérifier si le QR code correspond bien à un créneau valide ou a un abonnement
def verify_qr_code(qr_code_id, salle_scanner):
    try:
        #on créer un objet curseur sur notre base de donnée avec la méthode cursor()
        cursor = connection.cursor()
        
        # CAS Creneau
        if qr_code_id.startswith("Cre"):
        #on exécute la requête SQL avec execute()
            cursor.execute("""
                SELECT date_creneau, heure_debut, heure_fin, used, id_salle_sport
                FROM creneau 
                WHERE id_creneau = %s
            """, (qr_code_id,))

            # on ressort la ligne correspondante et on range chaque donnée dans un tableau avec fetchone()
            creneau = cursor.fetchone()
            # on vérifie si le créneau existe, si non on renvoie faux
            if (creneau is None):
                return None

            # on extrait les information de notre requête 
            date_creneau = creneau[0]
            heure_debut = creneau[1]
            heure_fin = creneau[2]
            used = creneau[3]
            id_salle_sport = creneau[4]

            #date et heure courante pour vérifier si on scanne le QR code dans le bon créneau
            current_date = datetime.now().date()
            current_time = datetime.now().time()

            # on vérifie si la date correspond bien
            if (current_date != date_creneau):
                return None
            # on vérifie si l'heure correspond bien
            if not (heure_debut <= current_time <= heure_fin):
                return None
            # on vérifie si la salle correspond bien
            if (id_salle_sport != salle_scanner):
                return None
            # on vérifie si le qr code a déja été utilisé
            if (used):
                return None

        # CAS Abonnement
        elif qr_code_id.startswith("Abn"):
            cursor.execute("""
                SELECT fin_abonnement
                FROM abonnement 
                WHERE id_abonnement = %s
            """, (qr_code_id,))
            abonnement = cursor.fetchone()
            if abonnement is None:
                return None

            fin_abonnement = abonnement[0]
            current_timestamp = datetime.now()
            if current_timestamp > fin_abonnement:
                return None
            
        else:
            return None
        
        # Si tout est valide, retourner le QR code
        return qr_code_id


    except Exception as e:
        print(f"Problème de connexion : {e}")
        return None

# Fonction pour marquer le créneau comme utilisé
def update_creneau(qr_code_id):
    try:
        cursor = connection.cursor()
        cursor.execute("UPDATE creneau SET used = TRUE WHERE id_creneau = %s", (qr_code_id,))
        connection.commit()
        return True
    except Exception as e:
        print(f"Problème de connexion : {e}")
        return False

def welcome_user(qr_code_id):
    try:
        cursor = connection.cursor()

        if(qr_code_id.startswith("Cre")):
            cursor.execute("""
                SELECT u.prenom, u.nom
                FROM utilisateur u
                JOIN creneau c ON u.id_utilisateur = c.id_utilisateur
                WHERE c.id_creneau = %s
                """, (qr_code_id,))
            user = cursor.fetchone()
            if user is None:
                print("Impossible d'obtenir le nom et prénom de l'utilisateur")
                return False
            else:
                print(user[0] + " " + user[1])
                return user
        elif(qr_code_id.startswith("Abn")):
            cursor.execute("""
                SELECT u.prenom, u.nom
                FROM utilisateur u
                JOIN abonne a ON u.id_utilisateur = a.id_abonne
                JOIN abonnement z ON a.id_abonnement = z.id_abonnement
                WHERE z.id_abonnement = %s
            """,(qr_code_id,))
            user = cursor.fetchone()
            if user is None:
                print("Impossible d'obtenir le nom et prénom de l'utilisateur")
                return False
            else:
                print(user[0] + " " + user[1])
                return user
                
    except Exception as e:
        print(f"Erreur dans la requête SQL pour obtenir l'utilisateur : {e}")
        return False
    
def start_server():
    #on se connecte à la base de donnée
    global connection
    connect_db()
    if (not connection):
        print("Impossible de démarrer le serveur sans connexion à la base de données.")
        return
    
    # on se connecte au socket avec l'adresse ip et le port
    host='127.0.0.1'
    port=10049
    
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen(1)

    print(f"Serveur en écoute sur {host}:{port}...")

    try:
        while (True):
            client_socket, client_address = server_socket.accept()
            print(f"Connexion acceptée de {client_address}")

            try:

                # 1 : On Vérifie le scanner
                scanner_id = receive_message(client_socket)
                salle_id = verify_scanner(scanner_id)
            
                if salle_id:
                    client_socket.send("true\n".encode('utf-8'))
                    print(f"Scanner VALID")
                else:
                    client_socket.send("false\n".encode('utf-8'))
                    print(f"Scanner INVALID")
                    continue
                
                # 2 : On vérifie si le QR code correspond bien au créneau, et s'il est valide
                qr_code_id = receive_message(client_socket)
                verified_qr = verify_qr_code(qr_code_id, salle_id)

                if verified_qr is not None:
                    client_socket.send("true\n".encode('utf-8'))
                    print(f"QR VALID")
                else:
                    client_socket.send("false\n".encode('utf-8'))
                    print(f"QR INVALID")
                    continue
                
                # 3 : Si le QR code est un creneau :
                if verified_qr.startswith("Cre"):
                    update_creneau(verified_qr)
                    print(f"QR UPDATED")

                #4 : On envoie les informations de l'utilisateur au client pour lui souhaiter la bienvenue sur le client
                user_info = welcome_user(qr_code_id)
                if user_info:
                    firstname = user_info[0]
                    lastname = user_info[1]
                    client_socket.send((firstname + "\n").encode('utf-8'))
                    client_socket.send((lastname + "\n").encode('utf-8'))  # Correction ici, nom de variable
                else:
                    client_socket.send("Erreur lors de la récupération des informations utilisateur.\n".encode('utf-8'))


            except Exception as e:
                print(f"Erreur : {e}")
            finally:
                client_socket.close()
                print("Connexion avec le client fermée.")
                
    finally:
        server_socket.close()
        connection.close()
        print("Connexion à la base de données fermée.")

if __name__ == "__main__":
    start_server()

    



