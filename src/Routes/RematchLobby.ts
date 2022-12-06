import { Router } from "express";
import { Client } from "../Client";
import { clients, expectedClientVersion } from "../Index";

const router = Router();

router.post("/", (req, res) => {
    let body: any;
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
        let lobby = client.Game;
        if (lobby) {
            // Lobby exists
            // Get player
            let player: Client = null;
            let side = null;
            if (lobby.playerO.UUID == client.UUID) {
                side = "O";
                player = clients.get(lobby.playerO.UUID);
            } else if (lobby.playerX.UUID == client.UUID) {
                side = "X";
                player = clients.get(lobby.playerX.UUID);
            }
            if (player) {
                // Player exists
                // Rematch
                if (side == "O") {
                    lobby.Rematch.O = true;
                } else if (side == "X") {
                    lobby.Rematch.X = true;
                }
                if (lobby.Rematch.O && lobby.Rematch.X) {
                    // Both players have agreed to rematch
                    // Reset game
                    lobby.lastUpdate = -1;
                    lobby.lastUpdateO = -1;
                    lobby.Rematch = {
                        O: false,
                        X: false
                    }
                    lobby.board = ["", "", "", "", "", "", "", "", ""];
                    lobby.Winner = null;
                    // Choose who goes first
                    lobby.turn = Math.random() > 0.5 ? "X" : "O";
                    client.Game = lobby;
                    clients.set(client.UUID, client);
                }
                res.status(200).send(JSON.stringify({
                    type: "rematch",
                }));
            } else {
                res.status(403).send("Player not found.");
            }
        } else {
            // Lobby does not exist
            let host: Client = null;
            clients.forEach((clientLoop) => {
                if (clientLoop.Game?.uuid === body.lobbyId) {
                    host = clientLoop;
                }
            });
            if (host) {
                lobby = host.Game;
                // Lobby exists
                let player: Client = null;
                let side = null;
                if (lobby.playerO.UUID == client.UUID) {
                    side = "O";
                    player = clients.get(lobby.playerO.UUID);
                } else if (lobby.playerX.UUID == client.UUID) {
                    side = "X";
                    player = clients.get(lobby.playerX.UUID);
                }

                // Rematch
                if (side == "O") {
                    lobby.Rematch.O = true;
                } else if (side == "X") {
                    lobby.Rematch.X = true;
                }
                if (lobby.Rematch.O && lobby.Rematch.X) {
                    // Both players have agreed to rematch
                    // Reset game
                    lobby.lastUpdate = -1;
                    lobby.lastUpdateO = -1;
                    lobby.Rematch = {
                        O: false,
                        X: false
                    }
                    lobby.Winner = null;
                    lobby.board = ["", "", "", "", "", "", "", "", ""];
                    // Choose who goes first
                    lobby.turn = Math.random() > 0.5 ? "X" : "O";
                    host.Game = lobby;
                    clients.set(host.UUID, host);
                }
            } else {
                res.status(403).send("Lobby not found.");
            }
        }
    } else {
        // Client does not exist, send a 403 error
        res.status(403).send("Client does not exist.");
    }
});

export default router;