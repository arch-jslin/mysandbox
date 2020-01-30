﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LookingGlass.ProWorkstation {
    [RequireComponent(typeof(InterProcessCommunicator))]
    public class ProWorkstationBaseIPC : MonoBehaviour {

        public ProWorkstationDisplay display;
        [Header("InterProcess Communicator")]
        [Tooltip("Automatically handle the IPC. If you change this to false, you have to set the reference and configure the IPC yourself")]
        public bool automaticallyHandleIPC = true;
        [Tooltip("IPC being referenced. Don't worry about this if this if automaticallyHandleIPC is set to true")]
        public InterProcessCommunicator ipc;

        public virtual void Awake() {

            ipc = GetComponent<InterProcessCommunicator>();

            // automatically handle the ports
            if (automaticallyHandleIPC) {
                if (display == ProWorkstationDisplay.Foldout2D) {
                    ipc.receiverPort = 8080;
                    ipc.senderPort = 8081;
                } else {
                    ipc.receiverPort = 8081;
                    ipc.senderPort = 8080;
                }
                ipc.role = InterProcessCommunicator.Role.Both;
            }

            // subscribe to the message received callback
            ipc.OnMessageReceived += ReceiveMessage;
        }

        public virtual void OnDestroy() {
            // unsubscribe when dead
            ipc.OnMessageReceived -= ReceiveMessage;
        }

        public virtual void Update() {
            // basic quit command. will quit the non-focused application through IPC as well
            if (Input.GetKeyDown(KeyCode.Escape)) {
                IPCQuit();
            }
        }

        // quits both the current application and any recipients
        public virtual void IPCQuit() {
            ipc.SendData("quit");
            Application.Quit();
        }

        public virtual void ReceiveMessage(string message) {
            // basic quit message receiver
            switch (message) {
                case "quit":
                    Application.Quit();
                    break;
            }
        }
    }
}