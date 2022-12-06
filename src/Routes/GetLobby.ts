import { Router } from "express";
import { Game } from "../Game";
import { clients, expectedClientVersion } from "../Index";

const router = Router()

router.post("/", (req, res) => {
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
            turn: lobby.turn,
            winner: lobby.Winner
        }));
    } else {
        // Lobby does not exist
        res.status(403).send("Lobby not found.");
    }
});

export default router;