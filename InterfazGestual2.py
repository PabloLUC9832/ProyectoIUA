#importamos librerias

#OpenCV
#Librería libre de visión artificial
#Ayuda a detectar movimientos y reconocimiento de objetos en imágenes
import cv2

#Mediapipe 
#Solución de manos con 21 puntos de referencia para identificar dedos y palma de la mano. 
#Utiliza Machine learning
#Documentación: https://google.github.io/mediapipe/solutions/hands#mediapipe-hands
import mediapipe as mp

#numpy
#Biblioteca que da soporte para crear vectores y matrices 
import numpy as np

#pyautogui
#Biblioteca que proporciona soporte para administrar las operaciones del mouse y el teclado a través del código
import pyautogui

#_____________________________________

#instanciamos la solución de MediaPipe 
mp_drawing = mp.solutions.drawing_utils #Para dibujar los resultados de las detecciones después
mp_hands = mp.solutions.hands #Implementar la solución hands

#Configurar captura de video con OpenCV
cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)

#Se define el color del pointer
color_mouse_pointer = (255, 0, 255)

# Se definen los puntos de la pantalla-juego
SCREEN_GAME_X_INI = 150
SCREEN_GAME_Y_INI = 160
SCREEN_GAME_X_FIN = 150 + 780
SCREEN_GAME_Y_FIN = 160 + 450

#Se calcula la relación de aspecto de la pantalla dividiendo los puntos
aspect_ratio_screen = (SCREEN_GAME_X_FIN - SCREEN_GAME_X_INI) / (SCREEN_GAME_Y_FIN - SCREEN_GAME_Y_INI)
print("aspect_ratio_screen:", aspect_ratio_screen)

#Se define una constante para dejar márgenes en el área azul
X_Y_INI = 100

def calculate_distance(x1, y1, x2, y2):
    p1 = np.array([x1, y1])
    p2 = np.array([x2, y2])
    return np.linalg.norm(p1 -p2)

def detect_finger_down(hand_landmarks):
    finger_down = False
    color_base = (255, 0, 112)
    color_index = (255, 198, 82)

    x_base1 = int(hand_landmarks.landmark[0].x * width)
    y_base1 = int(hand_landmarks.landmark[0].y * height)

    x_base2 = int(hand_landmarks.landmark[9].x * width)
    y_base2 = int(hand_landmarks.landmark[9].y * height)

    x_index = int(hand_landmarks.landmark[8].x * width)
    y_index = int(hand_landmarks.landmark[8].y * height)

    d_base = calculate_distance(x_base1, y_base1, x_base2, y_base2)
    d_base_index = calculate_distance(x_base1, y_base1, x_index, y_index)

    if d_base_index < d_base:
        finger_down = True
        color_base = (255, 0, 255)
        color_index = (255, 0, 255)

    cv2.circle(output, (x_base1, y_base1), 5, color_base, 2)
    cv2.circle(output, (x_index, y_index), 5, color_index, 2)
    cv2.line(output, (x_base1, y_base1), (x_base2, y_base2), color_base, 3)
    cv2.line(output, (x_base1, y_base1), (x_index, y_index), color_index, 1)

    return finger_down

#Configurar opciones de MediaPipe Hands
with mp_hands.Hands(
    static_image_mode=False, #imagen no estática
    max_num_hands=1, #Máximo número de manos
    min_detection_confidence=0.5) as hands: #mínimo nivel de confianza para la derección de manos
    
    #Mientras el programa está activo
    while True:
       
        #Se crea una ventana 
        ret, frame = cap.read()
        if ret == False:
            break
        height, width, _ = frame.shape
        frame = cv2.flip(frame, 1)

        # Dibujando un área proporcional a la del juego
        area_width = width - X_Y_INI * 2 #Ancho
        area_height = int(area_width / aspect_ratio_screen) #Alto
        aux_image = np.zeros(frame.shape, np.uint8)
        #Poner un recuadro con los puntos que hemos encontrado
        aux_image = cv2.rectangle(aux_image, (X_Y_INI, X_Y_INI), (X_Y_INI + area_width, X_Y_INI +area_height), (255, 0, 0), -1)
        output = cv2.addWeighted(frame, 1, aux_image, 0.7, 0)
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = hands.process(frame_rgb)
        
        #Si se detecta una mano 
        if results.multi_hand_landmarks is not None:
            for hand_landmarks in results.multi_hand_landmarks:
                #Acceder a las coordenadas del punto 9 de la mano
                x = int(hand_landmarks.landmark[9].x * width)
                y = int(hand_landmarks.landmark[9].y * height)
                xm = np.interp(x, (X_Y_INI, X_Y_INI + area_width), (SCREEN_GAME_X_INI, SCREEN_GAME_X_FIN))
                ym = np.interp(y, (X_Y_INI, X_Y_INI + area_height), (SCREEN_GAME_Y_INI, SCREEN_GAME_Y_FIN))

                #Mover el mouse
                pyautogui.moveTo(int(xm), int(ym))

                if detect_finger_down(hand_landmarks):
                    pyautogui.click()

                #Poner circulos en donde se encuentren los puntos de la mano
                cv2.circle(output, (x, y), 10, color_mouse_pointer, 3)
                cv2.circle(output, (x, y), 5, color_mouse_pointer, -1)
        #cv2.imshow('Frame', frame)
        cv2.imshow('output', output)
        if cv2.waitKey(1) & 0xFF == 27:
            break
cap.release()
cv2.destroyAllWindows()

#Implementar la función para dar click si se baja el dedo índice
#Seguir el video: https://www.youtube.com/watch?v=mMfbi4r9t1A&t=121s 
