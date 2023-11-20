if(other.bulleted_delay == 0)
{
    other.bulleted = 1
    other.team = team
    instance_destroy(other)
    instance_destroy(id)
}
