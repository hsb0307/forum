﻿using System;
using ENode.Domain;
using ENode.Infrastructure;
using Forum.Infrastructure;

namespace Forum.Domain.Replies
{
    /// <summary>回复聚合根
    /// </summary>
    public class Reply : AggregateRoot<string>
    {
        private string _postId;
        private string _parentId;
        private string _authorId;
        private string _body;
        private DateTime _createdOn;

        public Reply(string id, string postId, Reply parent, string authorId, string body)
            : base(id)
        {
            Assert.IsNotNullOrWhiteSpace("被回复的帖子", postId);
            Assert.IsNotNullOrWhiteSpace("回复作者", authorId);
            Assert.IsNotNullOrWhiteSpace("回复内容", body);
            if (body.Length > 4000)
            {
                throw new Exception("回复内容长度不能超过4000");
            }
            if (parent != null && id == parent.Id)
            {
                throw new ArgumentException(string.Format("回复的parentId不能是当前回复的Id:{0}", id));
            }
            ApplyEvent(new ReplyCreatedEvent( postId, parent == null ? null : parent.Id, authorId, body));
        }

        public void ChangeBody(string body)
        {
            Assert.IsNotNullOrWhiteSpace("回复内容", body);
            if (body.Length > 4000)
            {
                throw new Exception("回复内容长度不能超过4000");
            }
            ApplyEvent(new ReplyBodyChangedEvent( body));
        }
        public string GetAuthorId()
        {
            return _authorId;
        }
        public DateTime GetCreateTime()
        {
            return _createdOn;
        }

        private void Handle(ReplyCreatedEvent evnt)
        {
            _postId = evnt.PostId;
            _parentId = evnt.ParentId;
            _body = evnt.Body;
            _authorId = evnt.AuthorId;
            _createdOn = evnt.Timestamp;
        }
        private void Handle(ReplyBodyChangedEvent evnt)
        {
            _body = evnt.Body;
        }
    }
}