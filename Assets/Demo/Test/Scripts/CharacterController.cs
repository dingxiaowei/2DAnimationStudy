using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace SpineTest
{
    public class CharacterController : MonoBehaviour
    {
        readonly Vector3 flippedScale = new Vector3(-1, 1, 1);

        [Header("Character")]
        public Animator CharacterAnimator;
        [SerializeField] Transform Puppet = null;

        [Header("Movement")]
        [SerializeField] float acceleration = 0.0f;
        [SerializeField] float maxSpeed = 0.0f;
        [SerializeField] float jumpForce = 0.0f;
        [SerializeField] float minFlipSpeed = 0.1f;
        [SerializeField] float jumpGravityScale = 1.0f;
        [SerializeField] float fallGravityScale = 1.0f;
        [SerializeField] float groundedGravityScale = 1.0f;
        [SerializeField] bool resetSpeedOnLand = false;

        //[SerializeField] bool isAnimationJump = false;

        private Rigidbody2D controllerRigidbody;
        private Collider2D controllerCollider;
        private LayerMask softGroundMask;
        private LayerMask hardGroundMask;

        private int animatorGroundedBool;
        private int animatorWalkSpeed;
        private int animatorJumpTrigger;
        private int animatorAtk1Trigger;
        private int animatorAtk2Trigger;
        private int animatorMoveState;
        private int animatorIsRuning;

        private Vector2 movementInput;
        private bool jumpInput;
        private bool atk1Input;
        private bool atk2Input;
        private Vector2 prevVelocity;
        private GroundType groundType;
        private bool isFlipped;
        private bool isJumping;
        private bool isFalling;
        private bool isMoveing;
        private bool isRuning;


        public bool CanMove { get; set; }
        void Start()
        {
            controllerRigidbody = GetComponent<Rigidbody2D>();
            controllerCollider = GetComponent<Collider2D>();
            softGroundMask = LayerMask.GetMask("GroundSoft");
            hardGroundMask = LayerMask.GetMask("GroundHard");

            animatorGroundedBool = Animator.StringToHash("Grounded");
            animatorWalkSpeed = Animator.StringToHash("WalkSpeed");
            animatorJumpTrigger = Animator.StringToHash("Jump");
            animatorAtk1Trigger = Animator.StringToHash("Atk1");
            animatorAtk2Trigger = Animator.StringToHash("Atk2");
            animatorMoveState = Animator.StringToHash("MoveState");
            animatorIsRuning = Animator.StringToHash("IsRunning");

            CanMove = true;
        }

        void Update()
        {
            var keyboard = Keyboard.current;

            if (!CanMove || keyboard == null)
                return;
            float moveHorizontal = 0.0f;

            isMoveing = false;
            if (keyboard.leftArrowKey.isPressed || keyboard.aKey.isPressed)
            {
                moveHorizontal = -1.0f;
                isMoveing = true;
            }
            else if (keyboard.rightArrowKey.isPressed || keyboard.dKey.isPressed)
            {
                moveHorizontal = 1.0f;
                isMoveing = true;
            }

            //isRuning = false;
            if (keyboard.shiftKey.isPressed)
                isRuning = true;

            movementInput = new Vector2(moveHorizontal, 0);

            if (!isJumping && keyboard.spaceKey.wasPressedThisFrame)
                jumpInput = true;

            if (keyboard.jKey.wasPressedThisFrame)
                atk1Input = true;
            if (keyboard.kKey.wasPressedThisFrame)
                atk2Input = true;
        }

        void FixedUpdate()
        {
            UpdateGrounding();
            UpdateVelocity();
            UpdateDirection();
            UpdateJump();
            UpdateAtk();
            prevVelocity = controllerRigidbody.velocity;
        }

        private void UpdateGrounding()
        {
            if (controllerCollider.IsTouchingLayers(softGroundMask))
                groundType = GroundType.Soft;
            else if (controllerCollider.IsTouchingLayers(hardGroundMask))
                groundType = GroundType.Hard;
            else
                groundType = GroundType.None;

            CharacterAnimator.SetBool(animatorGroundedBool, groundType != GroundType.None);
        }

        private void UpdateAtk()
        {
            if (atk1Input)
            {
                CharacterAnimator.SetTrigger(animatorAtk1Trigger);
                atk1Input = false;
            }
            if (atk2Input)
            {
                CharacterAnimator.SetTrigger(animatorAtk2Trigger);
                atk2Input = false;
            }
        }

        private void UpdateVelocity()
        {
            Vector2 velocity = controllerRigidbody.velocity;
            velocity += movementInput * acceleration * Time.fixedDeltaTime;
            movementInput = Vector2.zero;
            velocity.x = Mathf.Clamp(velocity.x, -maxSpeed, maxSpeed);
            controllerRigidbody.velocity = velocity;
            var horizontalSpeedNormalized = Mathf.Abs(velocity.x) / maxSpeed;
            CharacterAnimator.SetFloat(animatorWalkSpeed, horizontalSpeedNormalized);
            CharacterAnimator.SetBool(animatorMoveState, isMoveing);
            CharacterAnimator.SetBool(animatorIsRuning, isRuning);
        }

        private void UpdateDirection()
        {
            if (controllerRigidbody.velocity.x > minFlipSpeed && isFlipped)
            {
                isFlipped = false;
                Puppet.localScale = flippedScale;
            }
            else if (controllerRigidbody.velocity.x < -minFlipSpeed && !isFlipped)
            {
                isFlipped = true;
                Puppet.localScale = Vector3.one;
            }
        }

        private void UpdateJump()
        {
            if (isJumping && controllerRigidbody.velocity.y < 0)
                isFalling = true;

            if (jumpInput && groundType != GroundType.None)
            {
                controllerRigidbody.AddForce(new Vector2(0, jumpForce), ForceMode2D.Impulse);

                CharacterAnimator.SetTrigger(animatorJumpTrigger);

                jumpInput = false;

                isJumping = true;
            }

            else if (isJumping && isFalling && groundType != GroundType.None)
            {
                if (resetSpeedOnLand)
                {
                    prevVelocity.y = controllerRigidbody.velocity.y;
                    controllerRigidbody.velocity = prevVelocity;
                }

                isJumping = false;
                isFalling = false;
            }
        }
    }
}