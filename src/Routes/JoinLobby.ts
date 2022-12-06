import { Router } from "express";
import { clients, expectedClientVersion } from "../Index";
import { BasicClient, Client } from "../Client";

const router = Router()

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
            if (host.Game.playerO === null) {
                host.Game.lastUpdate = -1;
                host.Game.lastUpdateO = -1;
                host.Game.Rematch = {
                    O: false,
                    X: false
                }
                host.Game.playerO = new BasicClient(client.UUID, client.Name);
                host.Game.board = ["", "", "", "", "", "", "", "", ""];
                host.Game.Winner = null;
                // Choose who goes first
                host.Game.turn = Math.random() > 0.5 ? "X" : "O";
                clients.set(host.UUID, host);
                res.status(200).send(JSON.stringify({
                    type: "lobby",
                    lobbyId: host.Game.uuid,
                }));
                console.log(`Client ${body.clientId} joined a lobby with uuid ${host.Game.uuid}`);
            } else {
                res.status(403).send("Lobby is full.");
            }
        } else {
            // Lobby does not exist
            console.log(`Client ${body.clientId} tried to join a lobby that does not exist.`);
            res.status(403).send("Lobby not found.");
        }
    } else {
        res.status(403).send("Client does not exist.");
    }
})

export default router;