import { Router } from "express";
import { Client } from "../Client";
import { Game } from "../Game";
import { clients, expectedClientVersion } from "../Index";

const router = Router()

router.post("/get", (req, res) => {
    let body: { GameVersion: string; lobbyId: string; clientId: string; };
    try {
        body = JSON.parse(Object.keys(req.body)[0]);
    } catch (error) {
        body = req.body;
    }
    if (body.GameVersion !== expectedClientVersion) {
        res.status(418).send("The client version is not compatible with the server version.");
        return;
    }

    // Get client from clients map
    let lobby: Game = null;
    clients.forEach((client) => {
        if (client.Game?.uuid === body.lobbyId) {
            lobby = client.Game;
        }
    });
    if (lobby) {
        // Lobby exists
        res.status(200).send(JSON.stringify({
            type: "lobby",
            lobbyId: lobby.uuid,
            board: lobby.board,
            turn: lobby.turn
        }));
    } else {
        // Lobby does not exist
        res.status(403).send("Lobby not found.");
    }
});

router.post("/", (req, res) => {
    let body: { GameVersion: string; clientId: string; lobbyId: string; };
    try {
        body = JSON.parse(Object.keys(req.body)[0]);
    } catch (error) {
        body = req.body;
    }
    if (body.GameVersion !== expectedClientVersion) {
        res.status(418).send("The client version is not compatible with the server version.");
        return;
    }

    // Get client from clients map
    const client = clients.get(body.clientId);
    if (client) {
        // Client exists
        // Get lobby from client
        const lobby = client.Game;
        if (lobby) {
            // Lobby exists
            client.LastHeartbeat = 0;
            client.Game.lastUpdate = 0;
            clients.set(body.clientId, client);
            res.status(200).send(JSON.stringify({
                type: "lobbyHeartbeat",
                lobbyId: lobby.uuid,
                board: lobby.board,
                playerX: lobby.playerX,
                playerO: lobby.playerO,
                winner: lobby.Winner,
                turn: lobby.turn
            }));
        } else {
            // Lobby does not exist

            // Check if the client is in a lobby
            let host: Client = null;
            clients.forEach((clientLoop) => {
                if (clientLoop.Game?.uuid === body.lobbyId) {
                    host = clientLoop;
                }
            });
            if (host) {
                // Client is in a lobby
                host.Game.lastUpdateO = 0;
                clients.set(host.UUID, host);
                res.status(200).send(JSON.stringify({
                    type: "lobbyHeartbeat",
                    lobbyId: host.Game.uuid,
                    board: host.Game.board,
                    playerX: host.Game.playerX,
                    playerO: host.Game.playerO,
                    winner: host.Game.Winner,
                    turn: host.Game.turn
                }));
            } else {
                // Client is not in a lobby
                console.log(`Client ${body.clientId} tried to heartbeat a lobby that does not exist.`);
                res.status(400).send("Lobby not found.");
            }
        }
    } else {
        // Client does not exist, send a 403 error
        console.log(`Client ${body.clientId} tried to heartbeat a lobby but client does not exist.`);
        res.status(403).send("Client does not exist.");
    }
})

export default router;