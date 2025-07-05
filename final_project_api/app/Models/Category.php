<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = ['name'];

    // Define relationship to Product
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function index()
{
    $categories = Category::all();
    return response()->json($categories);
}
}


