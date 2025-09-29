enum JoinStatus : String, Codable
{
    case invited = "invited"   //When invited but not joined yet
    case active = "active" //Joined and active
    case left = "left" //In case the user leaves the tournament or
}
