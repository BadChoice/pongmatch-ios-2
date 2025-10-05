enum LeagueStatus : String, Codable
{
    case draft   //When creating a match without an opponent
    case upcoming //When creating a match with opponent, but he needs to accept it
    case started //When challenge accepted
    case finished //When playing
    case canceled //If the game is cancel·led

}
