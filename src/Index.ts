import express from "express";
import { Client } from "./Client";

import connect from "./Routes/Connect";
import heartbeat from "./Routes/Heartbeat";
import createlobby from "./Routes/CreateLobby";
import setName from "./Routes/SetName";
import getlobbies from "./Routes/GetLobbies";
import lobbyheartbeat from "./Routes/LobbyHeartbeat";
import joinlobby from "./Routes/JoinLobby";
import getlobby from "./Routes/GetLobby";
import rematch from "./Routes/RematchLobby";
import setspace from "./Routes/SetSpace";
// CORS is a node package that enables Cross-Origin Resource Sharing
const cors = require('cors')

import { sleep } from "./Sleep";
import * as fs from 'fs';

const version = "1.0.0";
const expectedClientVersion = "1.0.0";
const app = express();
const port = 3000;
const clients: Map<string, Client> = new Map();

app.disable("x-powered-by");
app.use(express.urlencoded({
    extended: true
}));
app.use(express.json());
app.use(cors())

// start the express server
app.listen(port, () => {
    console.log(`Server started at http://localhost:${port}`);
    console.log(`Server version: ${version}`);
});

app.options('*', cors())
app.use("/connect", connect);
app.use("/heartbeat", heartbeat);
app.use("/lobby", createlobby);
app.use("/lobbies", getlobbies);
app.use("/client", setName);
app.use("/lobbyheartbeat", lobbyheartbeat);
app.use("/lobby/join", joinlobby);
app.use("/lobby/get", getlobby);
app.use("/space", setspace);
app.use("/rematch", rematch);

app.get("/", (req, res) => {
    res.send(fs.readFileSync("./Pages/Index.html", "utf-8"));
});

console.log("Starting client manager...");
clientManager();
// console.log(clientManager)

async function clientManager() {
    const connectedClients = clients
    connectedClients.forEach((client) => {
        // Increment the clients heartbeat
        client.LastHeartbeat += 1;
        if (client.Game) {
            // Check if the other player is still connected
            if (client.Game.playerO) {
                const otherPlayer = clients.get(client.Game.playerO.UUID);
                if (otherPlayer === undefined) {
                    // Other player is not connected
                    client.Game.playerO = undefined;
                    clients.set(client.UUID, client);
                }
            }
            // Check if the other players last game upate is greater than 2
            client.Game.lastUpdateO++;
            if (client.Game.lastUpdateO > 2) {
                if (client.Game.playerO) {
                    // Other player is not connected
                    client.Game.playerO = undefined;
                    clients.set(client.UUID, client);
                    console.log(`Removed player O from ${client.Game.uuid}`);
                }
            }
            client.Game.lastUpdate += 1;
            if (client.Game.lastUpdate > 2) {
                console.log(`Lobby ${client.Game.uuid} has been deleted due to inactivity.`);
                client.Game = null;
            }
            clients.set(client.UUID, client);
        }
        if (client.LastHeartbeat > 5) {
            clients.delete(client.UUID);
            console.log(`Client ${client.UUID} (${client.Name}) disconnected (heartbeat timeout)`);
        }
    });
    await sleep(1000);
    clientManager();
}

export {
    app,
    clients,
    version,
    expectedClientVersion
};