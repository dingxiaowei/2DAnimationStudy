namespace Base.Game.Core.CustomPhysics
{
    public interface IEntityComponent : ICustomPhysicsBase
    {
        void Awake();
        void Start();

        void Update(float deltaTime);
        void FixedUpdate();
    }
}
