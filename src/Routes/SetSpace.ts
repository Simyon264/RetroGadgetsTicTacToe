import { Router } from "express";
import { Client, BasicClient } from "../Client";
import { clients, expectedClientVersion } from "../Index";

const router = Router()

router.post("/", (req, res) => {
    let body: {
        space: any; GameVersion: string; clientId: string; lobbyId: string;
    };
    try {
        body = JSON.parse(Object.keys(req.body)[0]);
    } catch (error) {
        body = req.body;
    }
    if (body.GameVersion !== expectedClientVersion) {
        res.status(418).send("The client version is not compatible with the server version.");
        return;
    }
    const client = clients.get(body.clientId);
    if (client) {
        // Get lobby from given lobbyId
        let host: Client = null;
        clients.forEach((clientLoop) => {
            if (clientLoop.Game?.uuid === body.lobbyId) {
                host = clientLoop;
            }
        });
        if (host) {
            // Lobby exists
            // Check if the lobby is not full
            if (host.Game.playerO == undefined || host.Game.playerO == null) {
                res.status(403).send("Lobby is not full.");
                return;
            }
            // Check if the client is in that lobby
            let isClientInLobby = false;
            let side: ("X" | "O" | "" | "Tie") = "";
            if (host.Game.playerO.UUID == client.UUID) {
                isClientInLobby = true;
                side = "O";
            }
            if (host.Game.playerX.UUID == client.UUID) {
                isClientInLobby = true;
                side = "X";
            }
            if (!isClientInLobby) {
                res.status(403).send("Client is not in that lobby.");
                return;
            }

            // Get the space
            const space = host.Game.board[body.space - 1];
            if (space == "X" || space == "O") {
                res.status(403).send("Space is already taken.");
                return;
            }

            // If the turn is not the type to set the space to, return
            if (host.Game.turn != side) {
                res.status(403).send("It is not your turn.");
                return;
            }

            // Set the space
            host.Game.board[body.space - 1] = side;
            // Check if the game is over
            if (host.Game.board[0] == side && host.Game.board[1] == side && host.Game.board[2] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[3] == side && host.Game.board[4] == side && host.Game.board[5] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[6] == side && host.Game.board[7] == side && host.Game.board[8] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[0] == side && host.Game.board[3] == side && host.Game.board[6] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[1] == side && host.Game.board[4] == side && host.Game.board[7] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[2] == side && host.Game.board[5] == side && host.Game.board[8] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[0] == side && host.Game.board[4] == side && host.Game.board[8] == side) {
                host.Game.Winner = side;
            }
            if (host.Game.board[2] == side && host.Game.board[4] == side && host.Game.board[6] == side) {
                host.Game.Winner = side;
            }

            // Check if the game is a draw
            let isDraw = true;
            host.Game.board.forEach((space) => {
                if (space == "") {
                    isDraw = false;
                }
            });
            if (isDraw) {
                host.Game.Winner = "Tie";
            }

            // Update turn
            if (host.Game.turn == "X") {
                host.Game.turn = "O";
            } else {
                host.Game.turn = "X";
            }

            clients.set(host.UUID, host);
            res.status(200).send(JSON.stringify({
                type: "space",
            }));
        } else {
            // Lobby does not exist
            console.log(`Client ${body.clientId} tried to set a lobby that does not exist.`);
            res.status(403).send("Lobby not found.");
        }
    } else {
        res.status(403).send("Client does not exist.");
    }
});

export default router;