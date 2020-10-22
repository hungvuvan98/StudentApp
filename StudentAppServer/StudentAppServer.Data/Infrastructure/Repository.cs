using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;

namespace StudentAppServer.Data.Infrastructure
{
    public abstract class Repository<T> : IRepository<T> where T : class
    {
        protected readonly DbContext _context;
        protected readonly DbSet<T> _entities;

        public Repository(DbContext context)
        {
            _context = context;
            _entities = context.Set<T>();
        }

        public virtual void Add(T entity)
         => _entities.Add(entity);

        public virtual void AddRange(IEnumerable<T> entities)
        => _entities.AddRange(entities);

        public virtual void Update(T entity)
        => _entities.Update(entity);

        public virtual void UpdateRange(IEnumerable<T> entities)
        => _entities.UpdateRange(entities);

        public virtual void Remove(string id)
        => _entities.Remove(GetById(id));

        public virtual void RemoveByCondition(Expression<Func<T, bool>> predicate)
        => _entities.RemoveRange(Find(predicate));

        public virtual void Remove(T entity)
        => _entities.Remove(entity);

        public virtual void RemoveRange(IEnumerable<T> entities)
        => _entities.RemoveRange(entities);

        public virtual int Count()
        => _entities.Count();

        public virtual IEnumerable<T> Find(Expression<Func<T, bool>> predicate)
        => _entities.Where(predicate);

        public virtual T GetSingleOrDefault(Expression<Func<T, bool>> predicate)
        => _entities.SingleOrDefault(predicate);

        public virtual T GetById(string id)
        => _entities.Find(id);

        public virtual IEnumerable<T> GetAll()
       => _entities.ToList();
    }
}