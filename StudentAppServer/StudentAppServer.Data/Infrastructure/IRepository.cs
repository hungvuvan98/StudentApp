﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Infrastructure
{
    public interface IRepository<TEntity> where TEntity : class
    {
        void Add(TEntity entity);

        void AddRange(IEnumerable<TEntity> entities);

        void Update(TEntity entity);

        void UpdateRange(IEnumerable<TEntity> entities);

        void Remove(string id);

        void RemoveByCondition(Expression<Func<TEntity, bool>> predicate);

        void Remove(TEntity entity);

        void RemoveRange(IEnumerable<TEntity> entities);

        Task<int> Count();

        IEnumerable<TEntity> Find(Expression<Func<TEntity, bool>> predicate);

        TEntity GetSingleOrDefault(Expression<Func<TEntity, bool>> predicate);

        TEntity GetById(string id);

        IEnumerable<TEntity> GetAll();

        //IQueryable<TEntity> GetAll();
    }
}