resource "aws_iam_group" "k8sproject_demo_group" {
  name = "k8sproject-demo-group"
}

resource "aws_iam_policy" "k8sproject_policy" {
  name        = "k8sproject-policy"
  description = "A k8sproject policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CustomEKSProjectStatement2",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:ModifyVolume",
                "ec2:DetachVolume",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DescribeTags",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DescribeInstances",
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "k8sproject_demo_custom_eks_policy" {
    name       = "k8sproject-demo-custom-eks-policy"
    description = "Custom policy that is built for creating EKS with k8sproject Demo"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CustomPortWorxStatement1",
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:GetPolicyVersion",
                "iam:ListRoleTags",
                "iam:UntagRole",
                "iam:TagRole",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeletePolicy",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:ListInstanceProfileTags",
                "iam:AddRoleToInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:PassRole",
                "iam:DetachRolePolicy",
                "iam:ListPolicyTags",
                "iam:ListRolePolicies",
                "iam:ListPolicies",
                "iam:DeleteInstanceProfile",
                "iam:GetRole",
                "iam:GetInstanceProfile",
                "iam:GetPolicy",
                "iam:ListRoles",
                "iam:DeleteRole",
                "iam:ListInstanceProfiles",
                "iam:TagPolicy",
                "iam:CreatePolicy",
                "iam:ListPolicyVersions",
                "iam:UntagPolicy",
                "iam:UntagInstanceProfile",
                "iam:GetRolePolicy",
                "iam:DeletePolicyVersion",
                "iam:TagInstanceProfile",
                "eks:CreateCluster",
                "eks:CreateNodegroup",
                "eks:DescribeNodegroup",
                "eks:DescribeUpdate",
                "eks:DeleteCluster",
                "eks:DeleteNodegroup",
                "eks:UpdateNodegroupConfig",
                "eks:TagResource"
            ],
            "Resource": "*"
        }
    ]
  }
EOF
}

resource "aws_iam_policy_attachment" "k8sproject-attach" {
  name       = "k8sproject-attachment"
  groups     = [aws_iam_group.k8sproject_demo_group.name]
  policy_arn = aws_iam_policy.k8sproject_policy.arn
}

resource "aws_iam_policy_attachment" "CustomPortWorx-attach" {
  name       = "k8sproject_demo_custom_eks_policy_attachment"
  groups     = [aws_iam_group.k8sproject_demo_group.name]
  policy_arn = aws_iam_policy.k8sproject_demo_custom_eks_policy.arn
}

resource "aws_iam_group_policy_attachment" "aws_mp_ec2fullaccess" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "aws_mp_eks_vpc_controller" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}


resource "aws_iam_group_policy_attachment" "aws_mp_eks_farget_execution" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}


resource "aws_iam_group_policy_attachment" "aws_mp_eks_cni" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_group_policy_attachment" "aws_mp_eks_service" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_group_policy_attachment" "aws_mp_s3_readonly" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "aws_mp_eks_worker_node" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_group_policy_attachment" "aws_mp_eks_cluster" {
  group      = aws_iam_group.k8sproject_demo_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

output "k8sproject_group" {
   value = aws_iam_group.k8sproject_demo_group.name
}

output "k8sproject_group_path" {
   value = aws_iam_group.k8sproject_demo_group.path
}
