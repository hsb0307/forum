﻿using System.Linq;
using Forum.QueryServices;
using Forum.Web.Extensions;
using Microsoft.AspNetCore.Mvc;

namespace Forum.Web.Controllers
{
    public class SectionController : Controller
    {
        private readonly ISectionQueryService _queryService;

        public SectionController(ISectionQueryService queryService)
        {
            _queryService = queryService;
        }

        [HttpGet]
        public ActionResult Index(string sectionId)
        {
            var sections = _queryService.FindAllInculdeStatistic().Select(x=>x.ToViewModel(x.Id));
            return View(sections);
        }
        [HttpGet]
        public ActionResult GetAll()
        {
            return Json(new
            {
                success = true,
                data = _queryService.FindAll()
            });
        }
    }
}